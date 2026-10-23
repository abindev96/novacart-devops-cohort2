locals {
  # Last seven hex characters of the subscription GUID reduce global-name collisions.
  subscription_id_compact = replace(var.subscription_id, "-", "")
  subscription_suffix     = substr(local.subscription_id_compact, length(local.subscription_id_compact) - 7, 7)

  tags = {
    Project     = var.project_display_name
    Environment = var.environment == "dev" ? "Development" : "Production"
    ManagedBy   = "Terraform"
  }

  postgres_server_name = "${var.project_name}-ci-pg-${var.environment}-${local.subscription_suffix}"

  names = {
    app_resource_group     = "${var.project_name}-ci-rg-${var.environment}"
    network_resource_group = "${var.project_name}-ci-nrg-${var.environment}"
    postgres_resource_group = "${var.project_name}-ci-pgrg-${var.environment}"

    # Azure Container Registry names must be alphanumeric with no hyphens.
    acr                = "${var.project_name}cicr${var.environment}${local.subscription_suffix}"
    log_analytics      = "${var.project_name}-ci-law-${var.environment}"
    acr_pull_identity  = "${var.project_name}-ci-id-${var.environment}"

    vnet                = "${var.project_name}-ci-vnet-${var.environment}"
    aca_subnet          = "${var.project_name}-ci-snet-aca-${var.environment}"
    postgres_subnet     = "${var.project_name}-ci-snet-pg-${var.environment}"
    postgres_dns_zone   = "${local.postgres_server_name}.private.postgres.database.azure.com"
    postgres_dns_link   = "${var.project_name}-ci-pg-link-${var.environment}"

    # PostgreSQL server and Key Vault names must be globally unique.
    postgres_server = local.postgres_server_name
    key_vault       = "${var.project_name}cikv${var.environment}${local.subscription_suffix}"

    container_apps_environment = "${var.project_name}-ci-cae-${var.environment}"
    backend_app                = "${var.project_name}-ci-be-${var.environment}"
    frontend_app               = "${var.project_name}-ci-fe-${var.environment}"
  }
}


data "azurerm_key_vault" "postgres_credentials" {
  name                = var.key_vault_name
  resource_group_name = var.key_vault_resource_group_name
}

data "azurerm_key_vault_secret" "postgres_admin_password" {
  name         = var.postgres_admin_secret_name
  key_vault_id = data.azurerm_key_vault.postgres_credentials.id
}

module "platform" {
  source = "./modules/platform"

  location                    = var.location
  tags                        = local.tags
  resource_group_name         = local.names.app_resource_group
  acr_name                    = local.names.acr
  acr_sku                     = var.acr_sku
  log_analytics_name          = local.names.log_analytics
  log_analytics_retention_days = var.log_analytics_retention_days
  acr_pull_identity_name      = local.names.acr_pull_identity
}

module "network" {
  source = "./modules/network"

  location                         = var.location
  tags                             = local.tags
  resource_group_name              = local.names.network_resource_group
  vnet_name                        = local.names.vnet
  vnet_address_space               = var.vnet_address_space
  aca_subnet_name                  = local.names.aca_subnet
  aca_subnet_address_prefixes      = var.aca_subnet_address_prefixes
  postgres_subnet_name             = local.names.postgres_subnet
  postgres_subnet_address_prefixes  = var.postgres_subnet_address_prefixes
  postgres_dns_zone_name           = local.names.postgres_dns_zone
  postgres_dns_link_name           = local.names.postgres_dns_link
}

module "postgresql" {
  source = "./modules/postgresql"

  location                     = var.location
  tags                         = local.tags
  resource_group_name          = local.names.postgres_resource_group
  server_name                  = local.names.postgres_server
  database_name                = var.postgres_database_name
  postgres_version             = var.postgres_version
  postgres_zone                = var.postgres_zone
  admin_login                  = var.postgres_admin_login
  admin_password               = data.azurerm_key_vault_secret.postgres_admin_password.value
  sku_name                     = var.postgres_sku_name
  storage_mb                   = var.postgres_storage_mb
  storage_tier                 = var.postgres_storage_tier
  backup_retention_days        = var.postgres_backup_retention_days
  geo_redundant_backup_enabled = var.postgres_geo_redundant_backup_enabled
  delegated_subnet_id          = module.network.postgres_subnet_id
  private_dns_zone_id           = module.network.postgres_private_dns_zone_id

  depends_on = [module.network]
}

module "container_apps_environment" {
  source = "./modules/container-apps-environment"

  name                       = local.names.container_apps_environment
  location                   = var.location
  resource_group_name        = module.platform.resource_group_name
  infrastructure_subnet_id   = module.network.aca_subnet_id
  log_analytics_workspace_id = module.platform.log_analytics_workspace_id
  logs_destination           = "log-analytics"
  public_network_access      = "Enabled"
  workload_profile_name      = "Consumption"
  workload_profile_type      = "Consumption"

  depends_on = [module.platform, module.network]
}


module "container_apps" {
  count  = var.deploy_container_apps ? 1 : 0
  source = "./modules/container-apps"

  environment                  = var.environment
  tags                         = local.tags
  resource_group_name          = module.platform.resource_group_name
  container_app_environment_id = module.container_apps_environment.id
  acr_login_server             = module.platform.acr_login_server
  acr_pull_identity_id         = module.platform.acr_pull_identity_id
  image_tag                    = var.image_tag
  backend_app_name             = local.names.backend_app
  frontend_app_name            = local.names.frontend_app
  postgres_fqdn                = module.postgresql.server_fqdn
  postgres_admin_login         = var.postgres_admin_login
  postgres_admin_password      = data.azurerm_key_vault_secret.postgres_admin_password.value
  postgres_database_name       = var.postgres_database_name
  min_replicas                 = var.container_app_min_replicas
  max_replicas                 = var.container_app_max_replicas

  depends_on = [module.platform, module.postgresql, module.container_apps_environment]
}
