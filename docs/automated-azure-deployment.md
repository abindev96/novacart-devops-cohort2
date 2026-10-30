builds frontend and backend container images
githubactions CI will create frontend and backend images 

publishes images to a registry
CI pipeline will automatically push the image to acr with proper versioning

deploys to the Azure development environment:
GitHub Actions CD workflow deploys the images to Azure Container Apps in DEV.

updates Azure DEV to run a specific image version:
Container Apps are configured to use explicitly versioned images rather than the mutable latest tag

makes failures visible:
GitHub Actions reports workflow failures, while Azure Monitor and Log Analytics provide infrastructure and application monitoring.

can be verified after the run:GitHub Actions logs, ACR image tags, Container Apps revisions, and application health checks provide deployment evidence

uses credentials provided securely outside source files:GitHub Secrets, repository variables, and Azure OIDC authentication provide credentials without hardcoding them in source code.