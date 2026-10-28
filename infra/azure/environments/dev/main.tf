resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

module "networking" {
  source = "../../modules/networking"

  resource_group_name                = azurerm_resource_group.main.name
  location                           = azurerm_resource_group.main.location
  vnet_name                          = var.vnet_name
  vnet_address_space                 = var.vnet_address_space
  aca_subnet_name                    = var.aca_subnet_name
  aca_subnet_address_prefixes        = var.aca_subnet_address_prefixes
  postgres_subnet_name               = var.postgres_subnet_name
  postgres_subnet_address_prefixes   = var.postgres_subnet_address_prefixes
  postgres_private_dns_zone_name     = var.postgres_private_dns_zone_name
  postgres_dns_link_name             = var.postgres_dns_link_name
  tags                               = var.tags
}

module "container_registry" {
  source = "../../modules/container-registry"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  acr_name            = var.acr_name
  acr_sku             = var.acr_sku
  acr_identity_name   = var.acr_identity_name
  tags                = var.tags
}

module "monitoring" {
  source = "../../modules/monitoring"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  workspace_name      = var.log_analytics_workspace_name
  retention_in_days   = var.log_analytics_retention_days
  tags                = var.tags
}

module "key_vault" {
  source = "../../modules/key-vault"

  key_vault_name               = var.key_vault_name
  key_vault_resource_group_name = var.key_vault_resource_group_name
  identity_resource_group_name = azurerm_resource_group.main.name
  identity_location            = azurerm_resource_group.main.location
  backend_identity_name        = var.backend_kv_identity_name
  database_url_secret_name     = var.database_url_secret_name
  tags                         = var.tags
}

module "postgresql" {
  source = "../../modules/postgresql"

  resource_group_name            = azurerm_resource_group.main.name
  location                       = azurerm_resource_group.main.location
  server_name                    = var.postgres_server_name
  database_name                  = var.postgres_database_name
  administrator_login            = var.postgres_admin_login
  administrator_password_secret_name = var.postgres_admin_secret_name
  key_vault_id                   = module.key_vault.vault_id
  postgres_version               = var.postgres_version
  zone                           = var.postgres_zone
  delegated_subnet_id            = module.networking.postgres_subnet_id
  private_dns_zone_id             = module.networking.postgres_private_dns_zone_id
  sku_name                       = var.postgres_sku_name
  storage_mb                     = var.postgres_storage_mb
  storage_tier                    = var.postgres_storage_tier
  backup_retention_days          = var.postgres_backup_retention_days
  geo_redundant_backup_enabled   = var.postgres_geo_redundant_backup_enabled
  password_wo_version            = var.postgres_password_wo_version
  tags                           = var.tags

  depends_on = [module.networking, module.key_vault]
}

module "container_apps" {
  source = "../../modules/container-apps"

  resource_group_name                    = azurerm_resource_group.main.name
  environment                            = var.environment
  deploy_apps                            = var.deploy_container_apps
  location                               = azurerm_resource_group.main.location
  environment_name                       = var.container_app_environment_name
  environment_public_network_access      = var.container_app_environment_public_network_access
  aca_subnet_id                          = module.networking.aca_subnet_id
  log_analytics_workspace_id             = module.monitoring.workspace_id
  acr_login_server                       = module.container_registry.acr_login_server
  acr_identity_id                        = module.container_registry.acr_identity_id
  backend_kv_identity_id                 = module.key_vault.backend_identity_id
  key_vault_uri                          = module.key_vault.vault_uri
  database_url_secret_name               = var.database_url_secret_name
  backend_app_name                       = var.backend_app_name
  frontend_app_name                      = var.frontend_app_name
  image_tag                              = var.image_tag
  min_replicas                           = var.container_app_min_replicas
  max_replicas                           = var.container_app_max_replicas
  backend_cpu                            = var.backend_cpu
  backend_memory                         = var.backend_memory
  frontend_cpu                           = var.frontend_cpu
  frontend_memory                        = var.frontend_memory
  tags                                   = var.tags

  depends_on = [
    module.networking,
    module.monitoring,
    module.container_registry,
    module.key_vault,
    module.postgresql
  ]
}
