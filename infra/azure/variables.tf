variable "subscription_id" {
  description = "Azure subscription ID used for the deployment."
  type        = string

  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.subscription_id))
    error_message = "subscription_id must be a valid Azure subscription GUID."
  }
}

variable "project_name" {
  description = "Lowercase alphanumeric project slug used to generate resource names."
  type        = string
  default     = "novacart"

  validation {
    condition     = can(regex("^[a-z0-9]{3,16}$", var.project_name))
    error_message = "project_name must be 3-16 lowercase letters or numbers so generated Azure resource names remain within common length limits."
  }
}

variable "project_display_name" {
  description = "Readable project name used in Azure resource tags."
  type        = string
  default     = "NovaCart"
}

variable "environment" {
  description = "Environment represented by the selected Terraform workspace. Must be dev or prd."
  type        = string

  validation {
    condition     = contains(["dev", "prd"], var.environment)
    error_message = "environment must be dev or prd."
  }
}

variable "location" {
  description = "Azure region for workload resources."
  type        = string
  default     = "Central India"
}

variable "vnet_address_space" {
  description = "Virtual network address space for the selected environment."
  type        = list(string)
}

variable "aca_subnet_address_prefixes" {
  description = "Dedicated subnet prefixes for the Azure Container Apps environment."
  type        = list(string)
}

variable "postgres_subnet_address_prefixes" {
  description = "Dedicated delegated subnet prefixes for PostgreSQL Flexible Server."
  type        = list(string)
}

variable "acr_sku" {
  description = "Azure Container Registry SKU."
  type        = string
  default     = "Basic"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.acr_sku)
    error_message = "acr_sku must be Basic, Standard, or Premium."
  }
}

variable "log_analytics_retention_days" {
  description = "Log Analytics workspace retention in days."
  type        = number
  default     = 30

  validation {
    condition     = var.log_analytics_retention_days >= 30 && var.log_analytics_retention_days <= 730
    error_message = "log_analytics_retention_days must be between 30 and 730."
  }
}

variable "image_tag" {
  description = "Application image tag deployed to both Container Apps."
  type        = string
  default     = "v1.0.0"
}

variable "postgres_admin_login" {
  description = "PostgreSQL administrator login."
  type        = string
  default     = "novacart"
}

variable "postgres_admin_password" {
  description = "PostgreSQL administrator password. Supply through TF_VAR_postgres_admin_password; do not commit it to a tfvars file."
  type        = string
  sensitive   = true
}

variable "postgres_version" {
  description = "PostgreSQL major version."
  type        = string
  default     = "16"
}

variable "postgres_zone" {
  description = "Availability zone for PostgreSQL Flexible Server."
  type        = string
  default     = "2"
}

variable "postgres_sku_name" {
  description = "PostgreSQL Flexible Server SKU."
  type        = string
  default     = "B_Standard_B1ms"
}

variable "postgres_storage_mb" {
  description = "PostgreSQL Flexible Server storage in MB."
  type        = number
  default     = 32768
}

variable "postgres_storage_tier" {
  description = "PostgreSQL Flexible Server storage tier."
  type        = string
  default     = "P4"
}

variable "postgres_backup_retention_days" {
  description = "PostgreSQL backup retention in days."
  type        = number
  default     = 7

  validation {
    condition     = var.postgres_backup_retention_days >= 7 && var.postgres_backup_retention_days <= 35
    error_message = "postgres_backup_retention_days must be between 7 and 35."
  }
}

variable "postgres_geo_redundant_backup_enabled" {
  description = "Whether PostgreSQL geo-redundant backups are enabled."
  type        = bool
  default     = false
}

variable "postgres_database_name" {
  description = "Database name created inside PostgreSQL Flexible Server."
  type        = string
  default     = "novacart"
}

variable "container_app_min_replicas" {
  description = "Minimum replica count for each Container App."
  type        = number
  default     = 1
}

variable "container_app_max_replicas" {
  description = "Maximum replica count for each Container App."
  type        = number
  default     = 2
}
