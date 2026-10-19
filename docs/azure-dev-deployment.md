Development deployment:Terraform provisions the Azure infrastructure and deploys separate Docker images for the frontend and backend from Azure Container Registry (ACR) images.

Azure services:Azure Container Apps, Container Apps Environment, ACR, Virtual Network, subnets, Private DNS, PostgreSQL Flexible Server, and Log Analytics

Frontend → Backend: Nginx uses BACKEND_URL to proxy API requests to the backend's internal Container Apps HTTPS endpoint, with ingress target port 8080.

Backend → Database: The backend uses DATABASE_URL to connect to Azure Database for PostgreSQL Flexible Server through its private FQDN on port 5432

Expected development endpoints: Public HTTPS frontend; internal-only backend; PostgreSQL is privately accessible.

Post-deployment verification: Terraform deployment, frontend accessibility, backend API response (/api/products returning HTTP 200 through the frontend), backend startup logs, and internal backend API response were verified; the final frontend-to-backend proxy configuration was tested successfully