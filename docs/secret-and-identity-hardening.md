what secrets exist:PostgreSQL administrator credentials and application database credentials 

where they are stored:Azure Key Vault

how the application receives them:
Azure Container Apps retrieves required secrets from Key Vault through its managed identity and exposes them to the application as environment variables

how deployment authentication works:GitHub Actions authenticates to Azure using OIDC and a Microsoft Entra ID application registration, avoiding long-lived credentials in source files.

which identities are used by which components:GitHub Actions uses a federated service principal, Container Apps uses managed identities to access Key Vault and ACR, and Terraform uses its configured Azure authentication identity

how access is limited to what the app actually needs:Azure RBAC grants the Container App managed identity only the required Key Vault secret-reading permissions and ACR image-pull permissions.

how secret rotation would happen without source-code changes:Update the secret value or version in Key Vault,restart or deploy a new revision to make the updated value available.