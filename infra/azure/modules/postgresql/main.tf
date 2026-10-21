resource "azurerm_resource_group" "postgres" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_postgresql_flexible_server" "server" {
  name                = var.server_name
  resource_group_name = azurerm_resource_group.postgres.name
  location            = azurerm_resource_group.postgres.location

  version = var.postgres_version
  zone    = var.postgres_zone

  delegated_subnet_id = var.delegated_subnet_id
  private_dns_zone_id = var.private_dns_zone_id

  public_network_access_enabled = false

  administrator_login    = var.admin_login
  administrator_password = var.admin_password

  sku_name     = var.sku_name
  storage_mb   = var.storage_mb
  storage_tier = var.storage_tier

  backup_retention_days        = var.backup_retention_days
  geo_redundant_backup_enabled = var.geo_redundant_backup_enabled
}

resource "azurerm_postgresql_flexible_server_database" "database" {
  name      = var.database_name
  server_id = azurerm_postgresql_flexible_server.server.id

  charset   = "UTF8"
  collation = "en_US.utf8"
}
