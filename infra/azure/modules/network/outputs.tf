output "resource_group_name" {
  value = azurerm_resource_group.network.name
}

output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
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