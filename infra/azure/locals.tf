locals {
  # Use the last six hex characters of the subscription GUID as a deterministic
  # uniqueness suffix for globally-scoped names (ACR and PostgreSQL server).
  # ACR names cannot contain hyphens; this is an Azure naming-rule exception.
  subscription_suffix = substr(replace(lower(var.subscription_id), "-", ""), 26, 6)

  environment_label = var.environment == "dev" ? "Development" : "Production"

  tags = {
    Project     = var.project_display_name
    Environment = local.environment_label
  }

  # Workload resource names are generated from:
  # <project>-ci-<resource-shortform>-<workspace>
  names = {
    app_resource_group = "${var.project_name}-ci-rg-${var.environment}"
    # ACR accepts only 5-50 alphanumeric characters; no hyphens are allowed.
    acr                = "${var.project_name}ciacr${var.environment}${local.subscription_suffix}"
    log_analytics      = "${var.project_name}-ci-law-${var.environment}"
    acr_pull_identity  = "${var.project_name}-ci-uai-${var.environment}"

    network_rg        = "${var.project_name}-ci-netrg-${var.environment}"
    vnet              = "${var.project_name}-ci-vnet-${var.environment}"
    aca_subnet        = "${var.project_name}-ci-snet-aca-${var.environment}"
    postgres_subnet   = "${var.project_name}-ci-snet-pg-${var.environment}"
    postgres_dns_zone = "${var.project_name}-ci-pgdns-${var.environment}.private.postgres.database.azure.com"
    postgres_dns_link = "${var.project_name}-ci-dnslink-${var.environment}"

    postgres_rg     = "${var.project_name}-ci-pgrg-${var.environment}"
    # PostgreSQL server names are globally scoped, so include the suffix too.
    postgres_server = "${var.project_name}-ci-pg${local.subscription_suffix}-${var.environment}"

    container_env = "${var.project_name}-ci-cae-${var.environment}"
    backend_app   = "${var.project_name}-ci-be-${var.environment}"
    frontend_app  = "${var.project_name}-ci-fe-${var.environment}"
  }
}
