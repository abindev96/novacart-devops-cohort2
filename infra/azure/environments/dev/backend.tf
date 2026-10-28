terraform {
  backend "azurerm" {
    resource_group_name  = "novocart-ci-rg-dev"
    storage_account_name = "sanovocartcitfstate"
    container_name       = "tfstate"
    key                  = "novacart-dev.tfstate"

    # Keep these for local Azure CLI auth.
    # For GitHub Actions OIDC, use use_oidc = true and remove use_cli = true,
    # or use Azure/login first if retaining CLI-based backend auth.
    use_cli          = true
    use_azuread_auth = true
  }
}
