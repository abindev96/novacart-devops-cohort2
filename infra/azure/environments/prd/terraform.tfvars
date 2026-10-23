# FUTURE PRD configuration.
# Review SKU, HA, backup, recovery, logging, scaling, network and cost before production use.
subscription_id      = "c067343b-5c74-4217-813c-da18a4199741"
project_name         = "novacart"
project_display_name = "NovaCart"
environment          = "prd"
location             = "Central India"

# Separate, non-overlapping PRD network range.
vnet_address_space               = ["172.16.28.0/22"]
aca_subnet_address_prefixes      = ["172.16.28.0/23"]
postgres_subnet_address_prefixes = ["172.16.30.0/24"]

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

# Set true only after PRD images with tag v1.0.0 exist in the PRD ACR.
deploy_container_apps = false
