# Initialize with the backend file for the selected environment:
#   terraform init -reconfigure -backend-config=backend/dev.hcl
# or
#   terraform init -reconfigure -backend-config=backend/prd.hcl
terraform {
  backend "azurerm" {}
}