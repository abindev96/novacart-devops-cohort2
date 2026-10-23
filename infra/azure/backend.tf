# DEFAULT BACKEND: DEV.
# A plain `terraform init` uses these settings on a fresh checkout.
# To intentionally select PRD, override this configuration with:
# terraform init -reconfigure -backend-config=backend/prd.hcl
#
# Backend storage accounts and the tfstate container must be created before init.
terraform {
  backend "azurerm" {
    resource_group_name  = "novacart-ci-rg-tfstate"
    storage_account_name = "novacartcisaa4199741dev"
    container_name       = "tfstate"
    key                  = "novacart-dev.tfstate"

    use_azuread_auth = true
    use_cli          = true
  }
}