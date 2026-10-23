resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_container_registry" "cr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku                  = var.acr_sku
  admin_enabled        = false
  role_assignment_mode = "LegacyRegistryPermissions"
  tags                 = var.tags
}

resource "azurerm_log_analytics_workspace" "la" {
  name                = var.log_analytics_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku               = "PerGB2018"
  retention_in_days = var.log_analytics_retention_days
  tags              = var.tags
}

resource "azurerm_user_assigned_identity" "acr_pull" {
  name                = var.acr_pull_identity_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = var.tags
}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.cr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.acr_pull.principal_id
  principal_type       = "ServicePrincipal"


}
