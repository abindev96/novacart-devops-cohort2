variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "vnet_name" { type = string }
variable "vnet_address_space" { type = list(string) }
variable "aca_subnet_name" { type = string }
variable "aca_subnet_address_prefixes" { type = list(string) }
variable "postgres_subnet_name" { type = string }
variable "postgres_subnet_address_prefixes" { type = list(string) }
variable "postgres_private_dns_zone_name" { type = string }
variable "postgres_dns_link_name" { type = string }
variable "tags" {
  type    = map(string)
  default = {}
}
