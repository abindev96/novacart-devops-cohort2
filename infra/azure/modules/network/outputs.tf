output "resource_group_name" {
  value = azurerm_resource_group.network.name
}

output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  value = azurerm_virtual_network.vnet.name
}

output "aca_subnet_id" {
  value = azurerm_subnet.aca.id
}

output "postgres_subnet_id" {
  value = azurerm_subnet.postgres.id
}

output "postgres_private_dns_zone_id" {
  value = azurerm_private_dns_zone.postgres.id
}

output "postgres_private_dns_link_id" {
  value = azurerm_private_dns_zone_virtual_network_link.postgres.id
}