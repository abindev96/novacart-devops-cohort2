output "vault_id" { value = data.azurerm_key_vault.main.id }
output "vault_uri" { value = data.azurerm_key_vault.main.vault_uri }
output "backend_identity_id" { value = azurerm_user_assigned_identity.backend.id }
output "backend_identity_principal_id" { value = azurerm_user_assigned_identity.backend.principal_id }
