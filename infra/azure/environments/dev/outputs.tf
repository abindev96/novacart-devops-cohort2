output "resource_group_name" { value = azurerm_resource_group.main.name }
output "acr_login_server" { value = module.container_registry.acr_login_server }
output "postgres_server_fqdn" { value = module.postgresql.server_fqdn }
output "postgres_database_name" { value = module.postgresql.database_name }
output "container_app_environment_id" { value = module.container_apps.container_app_environment_id }
output "backend_container_app_fqdn" { value = module.container_apps.backend_fqdn }
output "frontend_url" { value = module.container_apps.frontend_url }
