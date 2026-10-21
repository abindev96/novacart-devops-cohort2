output "resource_group_name" {
  description = "Resource group containing ACR, Log Analytics and the managed identity."
  value       = module.platform.resource_group_name
}

output "network_resource_group_name" {
  description = "Resource group containing the VNet, subnets and PostgreSQL private DNS zone."
  value       = module.network.resource_group_name
}

output "postgres_resource_group_name" {
  description = "Resource group containing PostgreSQL Flexible Server."
  value       = module.postgresql.resource_group_name
}

output "azure_region" {
  description = "Azure region used by the workload."
  value       = var.location
}

output "acr_name" {
  description = "Azure Container Registry name."
  value       = module.platform.acr_name
}

output "acr_login_server" {
  description = "Azure Container Registry login server."
  value       = module.platform.acr_login_server
}

output "log_analytics_workspace_id" {
  description = "Log Analytics workspace resource ID."
  value       = module.platform.log_analytics_workspace_id
}

output "container_apps_environment_name" {
  description = "Container Apps managed environment name."
  value       = module.container_apps_environment.name
}

output "container_apps_environment_id" {
  description = "Container Apps managed environment resource ID."
  value       = module.container_apps_environment.id
}

output "container_apps_identity_id" {
  description = "User-assigned managed identity resource ID used for ACR pulls."
  value       = module.platform.acr_pull_identity_id
}

output "postgres_server_name" {
  description = "PostgreSQL Flexible Server name."
  value       = module.postgresql.server_name
}

output "postgres_server_fqdn" {
  description = "PostgreSQL Flexible Server FQDN."
  value       = module.postgresql.server_fqdn
}

output "postgres_database_name" {
  description = "PostgreSQL database name."
  value       = module.postgresql.database_name
}

output "backend_container_app_name" {
  description = "Backend Container App name."
  value       = module.container_apps.backend_name
}

output "backend_container_app_fqdn" {
  description = "Internal backend Container App FQDN."
  value       = module.container_apps.backend_fqdn
}

output "frontend_container_app_name" {
  description = "Frontend Container App name."
  value       = module.container_apps.frontend_name
}

output "frontend_url" {
  description = "Public frontend URL."
  value       = module.container_apps.frontend_url
}
