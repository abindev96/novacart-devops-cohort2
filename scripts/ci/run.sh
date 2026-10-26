create service principal creation for authentication,novocart-ci-rg-dev,sanovocartcitfstatedev,tfstate, storage account contributor role for storage account.

use_oidc         = true>> pinnidu add akanam cli auth kalanju

create container registry and push privilage for github

#check tags
novacart-kv-dev: new keyvault need to add
postgres-admin-password=novacart_local_only
database-url=postgresql://novacart:novacart_local_only@novacart-ci-pg-dev.postgres.database.azure.com:5432/novocart?sslmode=require
need to assign the keyvault officer to this login id  Key Vault Secrets User to the Terraform execution identity

 administrator_password_wo = ephemeral.azurerm_key_vault_secret.postgres_admin_password.value
administrator_password_wo_version = 1

