output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "acr_name" {
  value = azurerm_container_registry.cr.name
}

output "acr_id" {
  value = azurerm_container_registry.cr.id
}

output "acr_login_server" {
  value = azurerm_container_registry.cr.login_server
}

output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.la.id
}

output "acr_pull_identity_id" {
  value = azurerm_user_assigned_identity.acr_pull.id
}

output "acr_pull_identity_principal_id" {
  value = azurerm_user_assigned_identity.acr_pull.principal_id
}
