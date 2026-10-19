how PostgreSQL connectivity changed?previously the pgsql was accesed public endpoint with firewall.now backedn container is connecting to the pgsql via integrated vnet, using the private IP address resolved through the private DNS zone. public access is denied now

what Azure networking resources were required? a vnet, subnet for pgsql and aca,Private DNS zone,VNet link

how the application compute is connected to the network that can reach PostgreSQL
The application compute (the backend Azure Container App) connects to the network that can reach PostgreSQL through VNet integration at the Azure Container Apps environment level.

what name-resolution resources were required
Azure Private DNS zone and a Virtual Network (VNet) link

what changed in the app-to-database path
previously backend used the PostgreSQL server's public FQDN means connection travelled through the public endpoint and firewall will restrict the access.Now,the backend runs in an Azure Container Apps environment integrated with the VNet.The backend connects to PostgreSQL over the private network on TCP port 5432

how you verified the database is no longer public
from azure portal. settings> networking> connectivity method- pvt access

how you verified the application still works after the change?
site was available without any issues
