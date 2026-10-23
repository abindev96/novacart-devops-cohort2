output "backend_id" {
  value = azurerm_container_app.backend.id
}

output "backend_fqdn" {
  value = azurerm_container_app.backend.ingress[0].fqdn
}

output "frontend_id" {
  value = azurerm_container_app.frontend.id
}

output "frontend_fqdn" {
  value = azurerm_container_app.frontend.latest_revision_fqdn
}

output "frontend_url" {
  value = "https://${azurerm_container_app.frontend.latest_revision_fqdn}"
}
