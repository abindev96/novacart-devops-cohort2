resource "azurerm_container_app" "backend" {
  name                         = var.backend_app_name
  resource_group_name          = var.resource_group_name
  container_app_environment_id = var.container_app_environment_id

  revision_mode = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [var.acr_pull_identity_id]
  }

  registry {
    server   = var.acr_login_server
    identity = var.acr_pull_identity_id
  }

  secret {
    name  = "database-url"
    value = "postgresql://${var.postgres_admin_login}:${urlencode(var.postgres_admin_password)}@${var.postgres_fqdn}:5432/${var.postgres_database_name}?sslmode=require"
  }

  template {
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas

    container {
      name   = "backend"
      image  = "${var.acr_login_server}/novacart-backend:${var.image_tag}"
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name        = "DATABASE_URL"
        secret_name = "database-url"
      }

      env {
        name  = "APP_ENV"
        value = var.environment == "dev" ? "development" : "production"
      }

      env {
        name  = "LOG_LEVEL"
        value = "info"
      }
    }
  }

  ingress {
    external_enabled = false
    target_port      = 8080
    transport        = "http"

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}

resource "azurerm_container_app" "frontend" {
  name                         = var.frontend_app_name
  resource_group_name          = var.resource_group_name
  container_app_environment_id = var.container_app_environment_id

  revision_mode = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [var.acr_pull_identity_id]
  }

  registry {
    server   = var.acr_login_server
    identity = var.acr_pull_identity_id
  }

  template {
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas

    container {
      name   = "frontend"
      image  = "${var.acr_login_server}/novacart-frontend:${var.image_tag}"
      cpu    = 0.25
      memory = "0.5Gi"

      # The image entrypoint must substitute BACKEND_URL into Nginx config.
      # Setting an env var alone does not change a hard-coded Nginx upstream.
      env {
        name  = "BACKEND_URL"
        value = "${azurerm_container_app.backend.ingress[0].fqdn}"
      }
    }
  }

  ingress {
    external_enabled = true
    target_port      = 80
    transport        = "http"

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  tags = var.tags
}
