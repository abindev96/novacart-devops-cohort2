# DEFAULT ENVIRONMENT: DEV.
# Terraform automatically loads this file when commands run from the project root.
subscription_id       = "c067343b-5c74-4217-813c-da18a4199741"
project_name          = "novacart"
project_display_name  = "NovaCart"
environment           = "dev"
location              = "Central India"

# Original DEV address plan; ACA /23 and PostgreSQL /24 are inside the VNet /22.
vnet_address_space               = ["172.16.24.0/22"]
aca_subnet_address_prefixes      = ["172.16.24.0/23"]
postgres_subnet_address_prefixes = ["172.16.26.0/24"]

acr_sku                      = "Basic"
log_analytics_retention_days = 30
image_tag                    = "v1.0.0"

postgres_admin_login                  = "novacart"
postgres_version                      = "16"
postgres_zone                         = "2"
postgres_sku_name                     = "B_Standard_B1ms"
postgres_storage_mb                   = 32768
postgres_storage_tier                 = "P4"
postgres_backup_retention_days        = 7
postgres_geo_redundant_backup_enabled = false
postgres_database_name                = "novacart"

container_app_min_replicas = 1
container_app_max_replicas = 2

deploy_container_apps = false