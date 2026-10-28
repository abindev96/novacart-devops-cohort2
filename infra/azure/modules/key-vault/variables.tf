variable "key_vault_name" { type = string }
variable "key_vault_resource_group_name" { type = string }
variable "identity_resource_group_name" { type = string }
variable "identity_location" { type = string }
variable "backend_identity_name" { type = string }
variable "database_url_secret_name" {
  type    = string
  default = "database-url"
}
variable "tags" {
  type    = map(string)
  default = {}
}
