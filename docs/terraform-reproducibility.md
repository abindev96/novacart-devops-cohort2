how the Terraform is organized: 
main.tf
vairables.tf
outputs.tf
providers.tf
versions.tf
terraform.tfvars
Modules------Network
                 vnet, private dns

       ------Compute
                 pgsql,container registry, container app environment, container app

VARS ----------------dev, prd
terraform.tfstate


which values are environment-specific: prd.tfvars and dev.tfvars


which values should remain stable across runs? Terraform and provider versions,Resource names,Resource relationships, Naming and tagging conventions etc

how validation should be performed before apply? terraform validate,plan 

any conventions another engineer should follow when extending the code?
Use variables instead of hardcoding values,Follow naming conventions,Use outputs to share information,Preserve Terraform state,validation before deployment