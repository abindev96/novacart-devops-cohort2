variable "location" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "resource_group_name" {
  type = string
}

variable "server_name" {
  type = string
}

variable "database_name" {
  type = string
}

variable "postgres_version" {
  type = string
}

variable "postgres_zone" {
  type = string
}

variable "admin_login" {
  type = string
}

variable "admin_password" {
  type      = string
  sensitive = true
}

variable "sku_name" {
  type = string
}

variable "storage_mb" {
  type = number
}

variable "storage_tier" {
  type = string
}

variable "backup_retention_days" {
  type = number
}

variable "geo_redundant_backup_enabled" {
  type = bool
}

variable "delegated_subnet_id" {
  type = string
}

variable "private_dns_zone_id" {
  type = string
}
