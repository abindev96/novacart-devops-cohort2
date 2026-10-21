resource "azurerm_container_app_environment" "environment" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  infrastructure_subnet_id = var.infrastructure_subnet_id

  logs_destination           = var.logs_destination
  log_analytics_workspace_id = var.log_analytics_workspace_id
  public_network_access      = var.public_network_access

  workload_profile {
    name                  = var.workload_profile_name
    workload_profile_type = var.workload_profile_type
  }
}