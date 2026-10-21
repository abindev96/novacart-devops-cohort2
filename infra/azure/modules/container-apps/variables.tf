variable "environment" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "resource_group_name" {
  type = string
}

variable "container_app_environment_id" {
  type = string
}

variable "acr_login_server" {
  type = string
}

variable "acr_pull_identity_id" {
  type = string
}

variable "image_tag" {
  type = string
}

variable "backend_app_name" {
  type = string
}

variable "frontend_app_name" {
  type = string
}

variable "postgres_fqdn" {
  type = string
}

variable "postgres_admin_login" {
  type = string
}

variable "postgres_admin_password" {
  type      = string
  sensitive = true
}

variable "postgres_database_name" {
  type = string
}

variable "min_replicas" {
  type = number
}

variable "max_replicas" {
  type = number
}
