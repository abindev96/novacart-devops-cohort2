# Full PRD backend override. Used only when intentionally switching to PRD.
resource_group_name  = "novacart-ci-rg-tfstate"
storage_account_name = "novacartcisaa4199741prd"
container_name       = "tfstate"
key                  = "novacart-prd.tfstate"

use_azuread_auth = true
use_cli          = true