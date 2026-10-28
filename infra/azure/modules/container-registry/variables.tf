variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "acr_name" { type = string }
variable "acr_sku" {
  type    = string
  default = "Basic"
}
variable "acr_identity_name" { type = string }
variable "tags" {
  type    = map(string)
  default = {}
}
