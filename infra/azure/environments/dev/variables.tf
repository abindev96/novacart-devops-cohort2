variable "subscription_id" {
  description = "Azure subscription ID used by the azurerm provider."
  type        = string
}

variable "environment" {
  type = string
  validation {
    condition     = contains(["dev", "prd"], var.environment)
    error_message = "environment must be dev or prd."
  }
}

variable "resource_group_name" { type = string }
variable "location" {
  type    = string
  default = "Central India"
}
variable "tags" {
  type    = map(string)
  default = {}
}

variable "vnet_name" { type = string }
variable "vnet_address_space" { type = list(string) }
variable "aca_subnet_name" { type = string }
variable "aca_subnet_address_prefixes" { type = list(string) }
variable "postgres_subnet_name" { type = string }
variable "postgres_subnet_address_prefixes" { type = list(string) }
variable "postgres_private_dns_zone_name" { type = string }
variable "postgres_dns_link_name" { type = string }

variable "acr_name" { type = string }
variable "acr_sku" {
  type    = string
  default = "Basic"
}
variable "acr_identity_name" { type = string }

variable "key_vault_name" { type = string }
variable "key_vault_resource_group_name" { type = string }
variable "backend_kv_identity_name" { type = string }
variable "database_url_secret_name" {
  type    = string
  default = "database-url"
}
variable "postgres_admin_secret_name" {
  type    = string
  default = "postgres-admin-password"
}

variable "log_analytics_workspace_name" { type = string }
variable "log_analytics_retention_days" {
  type    = number
  default = 30
}

variable "postgres_server_name" { type = string }
variable "postgres_database_name" {
  type    = string
  default = "novocart"
}
variable "postgres_admin_login" {
  type    = string
  default = "novacart"
}
variable "postgres_version" {
  type    = string
  default = "16"
}
variable "postgres_zone" {
  type    = string
  default = "2"
}
variable "postgres_sku_name" {
  type    = string
  default = "B_Standard_B1ms"
}
variable "postgres_storage_mb" {
  type    = number
  default = 32768
}
variable "postgres_storage_tier" {
  type    = string
  default = "P4"
}
variable "postgres_backup_retention_days" {
  type    = number
  default = 7
}
variable "postgres_geo_redundant_backup_enabled" {
  type    = bool
  default = false
}
variable "postgres_password_wo_version" {
  type    = number
  default = 1
}

variable "deploy_container_apps" {
  description = "Set true after both container images have been pushed to ACR."
  type        = bool
  default     = false
}

variable "container_app_environment_name" { type = string }
variable "container_app_environment_public_network_access" {
  type    = string
  default = "Enabled"
  validation {
    condition     = contains(["Enabled", "Disabled"], var.container_app_environment_public_network_access)
    error_message = "Use Enabled or Disabled. Enabled is required for the current public frontend ingress."
  }
}
variable "backend_app_name" { type = string }
variable "frontend_app_name" { type = string }
variable "image_tag" {
  type    = string
  default = "v1.0.0"
}
variable "container_app_min_replicas" {
  type    = number
  default = 1
}
variable "container_app_max_replicas" {
  type    = number
  default = 2
}
variable "backend_cpu" {
  type    = number
  default = 0.25
}
variable "backend_memory" {
  type    = string
  default = "0.5Gi"
}
variable "frontend_cpu" {
  type    = number
  default = 0.25
}
variable "frontend_memory" {
  type    = string
  default = "0.5Gi"
}
