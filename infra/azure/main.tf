resource "terraform_data" "workspace_guard" {
  input = {
    workspace   = terraform.workspace
    environment = var.environment
  }

  lifecycle {
    precondition {
      condition     = contains(["dev", "prd"], terraform.workspace)
      error_message = "Select the Terraform workspace 'dev' or 'prd' before planning or applying. The default workspace is not used for deployments."
    }

    precondition {
      condition     = terraform.workspace == var.environment
      error_message = "The selected Terraform workspace must match var.environment. Use the matching environment tfvars file."
    }

    precondition {
      condition     = var.container_app_max_replicas >= var.container_app_min_replicas
      error_message = "container_app_max_replicas must be greater than or equal to container_app_min_replicas."
    }
  }
}

module "platform" {
  source = "./modules/platform"

  location                    = var.location
  tags                        = local.tags
  resource_group_name          = local.names.app_resource_group
  acr_name                     = local.names.acr
  acr_sku                      = var.acr_sku
  log_analytics_name           = local.names.log_analytics
  log_analytics_retention_days = var.log_analytics_retention_days
  acr_pull_identity_name       = local.names.acr_pull_identity

  depends_on = [terraform_data.workspace_guard]
}

module "network" {
  source = "./modules/network"

  location                         = var.location
  tags                             = local.tags
  resource_group_name              = local.names.network_rg
  vnet_name                        = local.names.vnet
  vnet_address_space               = var.vnet_address_space
  aca_subnet_name                  = local.names.aca_subnet
  aca_subnet_address_prefixes      = var.aca_subnet_address_prefixes
  postgres_subnet_name             = local.names.postgres_subnet
  postgres_subnet_address_prefixes = var.postgres_subnet_address_prefixes
  postgres_dns_zone_name           = local.names.postgres_dns_zone
  postgres_dns_link_name           = local.names.postgres_dns_link

  depends_on = [terraform_data.workspace_guard]
}

module "postgresql" {
  source = "./modules/postgresql"

  location                       = var.location
  tags                           = local.tags
  resource_group_name            = local.names.postgres_rg
  server_name                    = local.names.postgres_server
  database_name                  = var.postgres_database_name
  postgres_version               = var.postgres_version
  postgres_zone                  = var.postgres_zone
  admin_login                    = var.postgres_admin_login
  admin_password                 = var.postgres_admin_password
  sku_name                       = var.postgres_sku_name
  storage_mb                     = var.postgres_storage_mb
  storage_tier                   = var.postgres_storage_tier
  backup_retention_days          = var.postgres_backup_retention_days
  geo_redundant_backup_enabled   = var.postgres_geo_redundant_backup_enabled
  delegated_subnet_id            = module.network.postgres_subnet_id
  private_dns_zone_id             = module.network.postgres_private_dns_zone_id

  # Ensures the VNet link/private DNS zone are ready before server creation.
  depends_on = [module.network, terraform_data.workspace_guard]
}

module "container_apps_environment" {
  source = "./modules/container-apps-environment"

  name                       = local.names.container_env
  location                   = var.location
  resource_group_name        = module.platform.resource_group_name
  infrastructure_subnet_id   = module.network.aca_subnet_id
  log_analytics_workspace_id = module.platform.log_analytics_workspace_id
  logs_destination           = "log-analytics"
  public_network_access      = "Enabled"
  workload_profile_name      = "Consumption"
  workload_profile_type      = "Consumption"

  depends_on = [module.platform, module.network, terraform_data.workspace_guard]
}

module "container_apps" {
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
  postgres_admin_password      = var.postgres_admin_password
  postgres_database_name       = var.postgres_database_name
  min_replicas                 = var.container_app_min_replicas
  max_replicas                 = var.container_app_max_replicas

  # The module dependency also waits for the ACR AcrPull role assignment.
  depends_on = [module.platform, module.postgresql, module.container_apps_environment, terraform_data.workspace_guard]
}
