terraform {
  backend "azurerm" {
    resource_group_name  = "rg-novacart-tfstate"
    storage_account_name = "stnovacarttfstate01"
    container_name       = "tfstate"

    use_oidc         = true
    use_azuread_auth = true
  }
}