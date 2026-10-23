output "environment" {
  description = "Environment deployed by this configuration."
  value       = var.environment
}

output "app_resource_group_name" {
  description = "Resource group containing ACR, Log Analytics, identity and Container Apps resources."
  value       = module.platform.resource_group_name
}

output "network_resource_group_name" {
  description = "Resource group containing the VNet, subnets and private DNS resources."
  value       = module.network.resource_group_name
}

output "postgres_resource_group_name" {
  description = "Resource group containing PostgreSQL Flexible Server and its database."
  value       = module.postgresql.resource_group_name
}

output "acr_login_server" {
  description = "Azure Container Registry login server."
  value       = module.platform.acr_login_server
}

output "log_analytics_workspace_id" {
  description = "Log Analytics workspace resource ID."
  value       = module.platform.log_analytics_workspace_id
}

output "acr_pull_identity_id" {
  description = "User-assigned managed identity resource ID used for ACR pulls."
  value       = module.platform.acr_pull_identity_id
}

output "vnet_id" {
  description = "Virtual network resource ID."
  value       = module.network.vnet_id
}

output "aca_subnet_id" {
  description = "Azure Container Apps infrastructure subnet resource ID."
  value       = module.network.aca_subnet_id
}

output "postgres_subnet_id" {
  description = "PostgreSQL delegated subnet resource ID."
  value       = module.network.postgres_subnet_id
}

output "container_apps_environment_id" {
  description = "Container Apps Environment resource ID."
  value       = module.container_apps_environment.id
}

output "postgres_server_fqdn" {
  description = "PostgreSQL Flexible Server FQDN."
  value       = module.postgresql.server_fqdn
}

output "postgres_database_name" {
  description = "PostgreSQL database name."
  value       = module.postgresql.database_name
}

output "container_apps_deployed" {
  description = "Whether the frontend and backend Container Apps were enabled for this apply."
  value       = var.deploy_container_apps
}

output "frontend_url" {
  description = "Frontend URL when Container Apps are deployed; otherwise a message explaining the next step."
  value       = var.deploy_container_apps ? module.container_apps[0].frontend_url : "Not deployed yet. Push v1.0.0 images to ACR, set deploy_container_apps=true, and apply again."
}

output "backend_internal_fqdn" {
  description = "Internal backend FQDN when Container Apps are deployed."
  value       = var.deploy_container_apps ? module.container_apps[0].backend_fqdn : null
}
