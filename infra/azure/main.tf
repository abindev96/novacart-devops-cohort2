terraform {
  required_version = ">= 1.11.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.81.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "novocart-ci-rg-dev"
    storage_account_name = "sanovocartcitfstatedev"
    container_name       = "tfstate"
    key                  = "novacart-dev.tfstate"

    use_cli          = true
    use_azuread_auth = true
  }
}

provider "azurerm" {
  features {}

  subscription_id = "c067343b-5c74-4217-813c-da18a4199741"
}

# ------------------------------------------------------------
# Existing bootstrap resources
# These must already exist in Azure.
# ------------------------------------------------------------

data "azurerm_resource_group" "main" {
  name = "novocart-ci-rg-dev"
}

data "azurerm_container_registry" "main" {
  name                = "novocartcicrdev"
  resource_group_name = data.azurerm_resource_group.main.name
}

data "azurerm_key_vault" "main" {
  name                = "novacart-kv-dev"
  resource_group_name = data.azurerm_resource_group.main.name
}

# ------------------------------------------------------------
# Managed identities
# ------------------------------------------------------------

resource "azurerm_user_assigned_identity" "acr" {
  name                = "novacart-container-apps-identity"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
}

resource "azurerm_user_assigned_identity" "backend_kv" {
  name                = "novacart-backend-kv-identity-dev"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = data.azurerm_container_registry.main.id
  role_definition_name = "AcrPull"

  principal_id   = azurerm_user_assigned_identity.acr.principal_id
  principal_type = "ServicePrincipal"
}

resource "azurerm_role_assignment" "backend_kv_secrets" {
  scope                = "${data.azurerm_key_vault.main.id}/secrets/database-url"
  role_definition_name = "Key Vault Secrets User"

  principal_id   = azurerm_user_assigned_identity.backend_kv.principal_id
  principal_type = "ServicePrincipal"
}

# ------------------------------------------------------------
# Log Analytics
# ------------------------------------------------------------

resource "azurerm_log_analytics_workspace" "main" {
  name                = "novocart-ci-la-dev"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name

  sku               = "PerGB2018"
  retention_in_days = 30
}

# ------------------------------------------------------------
# Networking
# ------------------------------------------------------------

resource "azurerm_virtual_network" "main" {
  name                = "novocart-ci-vnet-dev"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name

  address_space = ["172.16.24.0/22"]
}

resource "azurerm_subnet" "aca" {
  name                 = "novocart-ci-sub-aca-dev"
  resource_group_name  = data.azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name

  address_prefixes = ["172.16.24.0/23"]

  delegation {
    name = "container-apps-delegation"

    service_delegation {
      name = "Microsoft.App/environments"

      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action"
      ]
    }
  }
}

resource "azurerm_subnet" "postgres" {
  name                 = "novocart-ci-sub-pg-dev"
  resource_group_name  = data.azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name

  address_prefixes = ["172.16.26.0/24"]

  delegation {
    name = "postgresql-delegation"

    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"

      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action"
      ]
    }
  }
}

# ------------------------------------------------------------
# PostgreSQL private DNS
# ------------------------------------------------------------

resource "azurerm_private_dns_zone" "postgres" {
  name                = "novacart-ci-pg-dev.private.postgres.database.azure.com"
  resource_group_name = data.azurerm_resource_group.main.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgres" {
  name                  = "novacart-ci-pg-dev-dns-link"
  resource_group_name   = data.azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.postgres.name
  virtual_network_id    = azurerm_virtual_network.main.id

  registration_enabled = false
}

# ------------------------------------------------------------
# PostgreSQL administrator password from Key Vault
# Requires Terraform 1.11+ and provider support for ephemeral secrets.
# ------------------------------------------------------------

ephemeral "azurerm_key_vault_secret" "postgres_admin_password" {
  name         = "postgres-admin-password"
  key_vault_id = data.azurerm_key_vault.main.id
}

resource "azurerm_postgresql_flexible_server" "main" {
  name                = "novacart-ci-pg-dev"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location

  version = "16"
  zone    = "2"

  delegated_subnet_id = azurerm_subnet.postgres.id
  private_dns_zone_id = azurerm_private_dns_zone.postgres.id

  public_network_access_enabled = false

  administrator_login = "novacart"

  administrator_password_wo         = ephemeral.azurerm_key_vault_secret.postgres_admin_password.value
  administrator_password_wo_version = 1

  sku_name     = "B_Standard_B1ms"
  storage_mb   = 32768
  storage_tier = "P4"

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false

  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.postgres
  ]
}

resource "azurerm_postgresql_flexible_server_database" "main" {
  name      = "novocart"
  server_id = azurerm_postgresql_flexible_server.main.id

  charset   = "UTF8"
  collation = "en_US.utf8"
}

# ------------------------------------------------------------
# Container Apps Environment
# ------------------------------------------------------------

resource "azurerm_container_app_environment" "main" {
  name                       = "novocart-ci-cae-dev"
  location                   = data.azurerm_resource_group.main.location
  resource_group_name        = data.azurerm_resource_group.main.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  infrastructure_subnet_id = azurerm_subnet.aca.id

  workload_profile {
    name                  = "Consumption"
    workload_profile_type = "Consumption"
  }
}

# ------------------------------------------------------------
# Backend Container App
# ------------------------------------------------------------

resource "azurerm_container_app" "backend" {
  name                         = "novacart-ci-be-ca-dev"
  resource_group_name          = data.azurerm_resource_group.main.name
  container_app_environment_id = azurerm_container_app_environment.main.id

  revision_mode = "Single"

  identity {
    type = "UserAssigned"

    identity_ids = [
      azurerm_user_assigned_identity.acr.id,
      azurerm_user_assigned_identity.backend_kv.id
    ]
  }

  registry {
    server   = data.azurerm_container_registry.main.login_server
    identity = azurerm_user_assigned_identity.acr.id
  }

  secret {
    name                = "database-url"
    key_vault_secret_id = "${data.azurerm_key_vault.main.vault_uri}secrets/database-url"
    identity            = azurerm_user_assigned_identity.backend_kv.id
  }

  template {
    min_replicas = 1
    max_replicas = 2

    container {
      name   = "backend"
      image  = "${data.azurerm_container_registry.main.login_server}/novacart-backend:v1.0.0"
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name        = "DATABASE_URL"
        secret_name = "database-url"
      }

      env {
        name  = "APP_ENV"
        value = "dev"
      }

      env {
        name  = "LOG_LEVEL"
        value = "info"
      }
    }
  }

  ingress {
    external_enabled = false
    target_port      = 8080
    transport        = "http"

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  depends_on = [
    azurerm_role_assignment.acr_pull,
    azurerm_role_assignment.backend_kv_secrets,
    azurerm_postgresql_flexible_server_database.main
  ]
}

# ------------------------------------------------------------
# Frontend Container App
# ------------------------------------------------------------

resource "azurerm_container_app" "frontend" {
  name                         = "novacart-ci-fe-ca-dev"
  resource_group_name          = data.azurerm_resource_group.main.name
  container_app_environment_id = azurerm_container_app_environment.main.id

  revision_mode = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.acr.id]
  }

  registry {
    server   = data.azurerm_container_registry.main.login_server
    identity = azurerm_user_assigned_identity.acr.id
  }

  template {
    min_replicas = 1
    max_replicas = 2

    container {
      name   = "frontend"
      image  = "${data.azurerm_container_registry.main.login_server}/novacart-frontend:v1.0.0"
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name  = "BACKEND_URL"
        value = "https://${azurerm_container_app.backend.ingress[0].fqdn}"
      }
    }
  }

  ingress {
    external_enabled = true
    target_port      = 80
    transport        = "http"

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  depends_on = [
    azurerm_role_assignment.acr_pull,
    azurerm_container_app.backend
  ]
}