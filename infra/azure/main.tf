
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.81.0"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = "c067343b-5c74-4217-813c-da18a4199741"
}

locals {
  location = "Central India"

  tags = {
    Project     = "NovaCart"
    Environment = "Development"
  }

  
  

  image_tag = "v1.0.0"
}


# resource group


resource "azurerm_resource_group" "rg" {
  name     = "NOVOCART-CI-ACA-DEV"
  location = local.location
  tags     = local.tags
}

# Azure Container Registry
resource "azurerm_container_registry" "cr" {
  name                = "novocartdevcr"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku                   = "Basic"
  admin_enabled         = false
  role_assignment_mode  = "LegacyRegistryPermissions"

  
}

# loganalytic workspace
resource "azurerm_log_analytics_workspace" "la" {
  name                = "novo-ci-lws"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku               = "PerGB2018"
  retention_in_days = 30

  
}

# Managed identity for pulling images from ACR
resource "azurerm_user_assigned_identity" "acr_pull" {
  name                = "novacart-acr-pull-identity"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = local.tags
}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.cr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.acr_pull.principal_id

  skip_service_principal_aad_check = true
}




resource "azurerm_resource_group" "vnetrg" {
  name     = "NOVO-CI-GEN"
  location = local.location
  
}

resource "azurerm_virtual_network" "vnet" {
  name                = "NOVO-CI-VNET"
  location            = azurerm_resource_group.vnetrg.location
  resource_group_name = azurerm_resource_group.vnetrg.name

  address_space = ["172.16.24.0/22"]

  
}

# Dedicated subnet for Azure Container Apps infrastructure
resource "azurerm_subnet" "acasubnet" {
  name                 = "novo-ci-aca-infrastructure"
  resource_group_name  = azurerm_resource_group.vnetrg.name
  virtual_network_name = azurerm_virtual_network.vnet.name

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

# Dedicated subnet for PostgreSQL Flexible Server
resource "azurerm_subnet" "pgsubnet" {
  name                 = "novo-ci-pg-dev"
  resource_group_name  = azurerm_resource_group.vnetrg.name
  virtual_network_name = azurerm_virtual_network.vnet.name

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

resource "azurerm_private_dns_zone" "pgdnszone" {
  name                = "novpgdev.private.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.vnetrg.name

  tags = local.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "pgdnszone" {
  name                  = "novo-ci-pg-dns-link"
  resource_group_name   = azurerm_resource_group.vnetrg.name
  private_dns_zone_name = azurerm_private_dns_zone.pgdnszone.name
  virtual_network_id    = azurerm_virtual_network.vnet.id

  registration_enabled = false
}

#pgsql

resource "azurerm_resource_group" "pgrg" {
  name     = "NOVO-CI-PSQLDB-DEV"
  location = local.location
  tags     = local.tags
}

resource "azurerm_postgresql_flexible_server" "pg" {
  name                = "novo-ci-pg-dev"
  resource_group_name = azurerm_resource_group.pgrg.name
  location            = azurerm_resource_group.pgrg.location

  version = "16"
  zone    = "2"

  delegated_subnet_id = azurerm_subnet.pgsubnet.id
  private_dns_zone_id = azurerm_private_dns_zone.pgdnszone.id

  public_network_access_enabled = false

  administrator_login    = "novacart"
  administrator_password = var.postgres_admin_password

  sku_name   = "B_Standard_B1ms"
  storage_mb = 32768
  storage_tier = "P4"

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false

  

  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.pgdnszone
  ]

  
}

resource "azurerm_postgresql_flexible_server_database" "pgdb" {
  name      = "novacart"
  server_id = azurerm_postgresql_flexible_server.pg.id

  charset   = "UTF8"
  collation = "en_US.utf8"
}

#container app 

resource "azurerm_container_app_environment" "cae" {
  name                = "Novocart-Dev-Container-Apps-Environment"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  infrastructure_subnet_id = azurerm_subnet.acasubnet.id

  logs_destination           = "log-analytics"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.la.id
  public_network_access      = "Enabled"

  workload_profile {
    name                  = "Consumption"
    workload_profile_type = "Consumption"
  }

  
}


# BACKEND CONTAINER APP


resource "azurerm_container_app" "backend" {
  name                         = "novocart-be-ci-aca-dev"
  resource_group_name          = azurerm_resource_group.rg.name
  container_app_environment_id = azurerm_container_app_environment.cae.id

  revision_mode = "Single"

  identity {
    type = "UserAssigned"

    identity_ids = [
      azurerm_user_assigned_identity.acr_pull.id
    ]
  }

  registry {
    server   = azurerm_container_registry.cr.login_server
    identity = azurerm_user_assigned_identity.acr_pull.id
  }

  secret {
    name = "database-url"

    value = "postgresql://novacart:${urlencode(var.postgres_admin_password)}@${azurerm_postgresql_flexible_server.pg.fqdn}:5432/novacart?sslmode=require"
  }

  template {
    min_replicas = 0
    max_replicas = 2

    container {
      name   = "backend"
      image  = "${azurerm_container_registry.cr.login_server}/novacart-backend:${local.image_tag}"
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name        = "DATABASE_URL"
        secret_name = "database-url"
      }

      env {
        name  = "APP_ENV"
        value = "development"
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
    azurerm_postgresql_flexible_server_database.pgdb
  ]

  
}

#frontend aca

resource "azurerm_container_app" "frontend" {
  name                         = "novocart-fe-ci-aca-dev"
  resource_group_name          = azurerm_resource_group.rg.name
  container_app_environment_id = azurerm_container_app_environment.cae.id

  revision_mode = "Single"

  identity {
    type = "UserAssigned"

    identity_ids = [
      azurerm_user_assigned_identity.acr_pull.id
    ]
  }

  registry {
    server   = azurerm_container_registry.cr.login_server
    identity = azurerm_user_assigned_identity.acr_pull.id
  }

  template {
    min_replicas = 0
    max_replicas = 2

    container {
      name   = "frontend"
      image  = "${azurerm_container_registry.cr.login_server}/novacart-frontend:${local.image_tag}"
      cpu    = 0.25
      memory = "0.5Gi"

      # The Nginx image must substitute this value into its
      # configuration at startup; setting an environment variable
      # alone does not update a hard-coded Nginx upstream.
      env {
        name  = "BACKEND_URL"
        value = "http://${azurerm_container_app.backend.ingress[0].fqdn}"
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
    azurerm_role_assignment.acr_pull
  ]

  tags = local.tags
}


# OUTPUTS


output "acr_login_server" {
  value = azurerm_container_registry.cr.login_server
}

output "postgresql_fqdn" {
  value = azurerm_postgresql_flexible_server.pg.fqdn
}

output "backend_internal_fqdn" {
  value = azurerm_container_app.backend.ingress[0].fqdn
}

output "frontend_url" {
  value = "https://${azurerm_container_app.frontend.ingress[0].fqdn}"
}
