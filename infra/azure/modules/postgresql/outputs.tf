output "resource_group_name" {
  value = azurerm_resource_group.postgres.name
}

output "server_id" {
  value = azurerm_postgresql_flexible_server.server.id
}

output "server_name" {
  value = azurerm_postgresql_flexible_server.server.name
}

output "server_fqdn" {
  value = azurerm_postgresql_flexible_server.server.fqdn
}

output "database_name" {
  value = azurerm_postgresql_flexible_server_database.database.name
}