output "backend_name" {
  value = azurerm_container_app.backend.name
}

output "backend_fqdn" {
  value = azurerm_container_app.backend.ingress[0].fqdn
}

output "frontend_name" {
  value = azurerm_container_app.frontend.name
}

output "frontend_fqdn" {
  value = azurerm_container_app.frontend.latest_revision_fqdn
}

output "frontend_url" {
  value = "https://${azurerm_container_app.frontend.latest_revision_fqdn}"
}