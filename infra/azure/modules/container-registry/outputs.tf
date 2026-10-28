output "acr_id" { value = azurerm_container_registry.main.id }
output "acr_name" { value = azurerm_container_registry.main.name }
output "acr_login_server" { value = azurerm_container_registry.main.login_server }
output "acr_identity_id" { value = azurerm_user_assigned_identity.pull.id }
output "acr_identity_principal_id" { value = azurerm_user_assigned_identity.pull.principal_id }
