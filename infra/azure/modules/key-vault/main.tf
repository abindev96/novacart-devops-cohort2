data "azurerm_key_vault" "main" {
  name                = var.key_vault_name
  resource_group_name = var.key_vault_resource_group_name
}

# This identity is assigned to the backend only for the Key Vault reference.
resource "azurerm_user_assigned_identity" "backend" {
  name                = var.backend_identity_name
  resource_group_name = var.identity_resource_group_name
  location            = var.identity_location
  tags                = var.tags
}

# Secret-level RBAC scope limits this identity to database-url.
# The Key Vault must use the Azure RBAC permission model.
resource "azurerm_role_assignment" "database_url_reader" {
  scope                            = "${data.azurerm_key_vault.main.id}/secrets/${var.database_url_secret_name}"
  role_definition_name             = "Key Vault Secrets User"
  principal_id                     = azurerm_user_assigned_identity.backend.principal_id
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true
}
