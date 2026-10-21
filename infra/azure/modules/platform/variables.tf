variable "location" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "resource_group_name" {
  type = string
}

variable "acr_name" {
  type = string
}

variable "acr_sku" {
  type = string
}

variable "log_analytics_name" {
  type = string
}

variable "log_analytics_retention_days" {
  type = number
}

variable "acr_pull_identity_name" {
  type = string
}