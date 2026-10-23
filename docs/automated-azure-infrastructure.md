Infrastructure managed: Terraform manages Azure Resource Groups, ACR, networking, private DNS, PostgreSQL, Log Analytics, Container Apps Environment, and optionally Container Apps.



When the workflow runs: On pull requests targeting main for validation, and on changes pushed or merged into main for deployment.



Review before apply: Pull requests run Terraform format and validation checks; the deployment workflow generates a plan and automatically applies it after merging, without a separate manual plan approval.



Terraform state protection: State is stored in Azure Blob Storage with separate state keys for DEV, PRD, and future QA, protected through Microsoft Entra authentication and RBAC.



Authentication: GitHub Actions uses OIDC federation with Microsoft Entra ID instead of long-lived Azure client secrets.



Workflow results and failures: GitHub repository → Actions shows workflow runs, execution logs, validation results, and deployment errors.



Azure development assumptions: The state Storage Account, Blob container, Key Vault, GitHub OIDC configuration, required permissions, and environment-specific Terraform variables must be configured correctly.



Production risks: Automatic apply without approval, broad Azure permissions, shared-module changes affecting multiple environments, insufficient state isolation, and unreviewed production plans are risky.