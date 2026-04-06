locals {
  infisical_site_url     = "https://${var.INFISICAL_APP_NAME}.${var.BASE_DOMAIN}"
  infisical_dev_site_url = "https://${var.INFISICAL_APP_NAME}-dev.${var.BASE_DOMAIN}"

  infisical_env = join("\n", [
    "ENCRYPTION_KEY=${var.INFISICAL_ENCRYPTION_KEY}",
    "AUTH_SECRET=${var.INFISICAL_AUTH_SECRET}",
    "DB_PASSWORD=${var.INFISICAL_DB_PASSWORD}",
    "DB_CONNECTION_URI=postgres://infisical:${var.INFISICAL_DB_PASSWORD}@postgres:5432/infisical",
    "REDIS_URL=redis://redis:6379",
    "SITE_URL=${local.infisical_site_url}",
    "CLIENT_ID_GOOGLE_LOGIN=${var.INFISICAL_CLIENT_ID_GOOGLE_LOGIN}",
    "CLIENT_SECRET_GOOGLE_LOGIN=${var.INFISICAL_CLIENT_SECRET_GOOGLE_LOGIN}",
    "SMTP_HOST=${var.INFISICAL_SMTP_HOST}",
    "SMTP_PORT=${var.INFISICAL_SMTP_PORT}",
    "SMTP_USERNAME=${var.INFISICAL_SMTP_USERNAME}",
    "SMTP_PASSWORD=${var.INFISICAL_SMTP_PASSWORD}",
    "SMTP_FROM_ADDRESS=${var.INFISICAL_SMTP_FROM_ADDRESS}",
    "SMTP_FROM_NAME=${var.INFISICAL_SMTP_FROM_NAME}",
    "SMTP_REQUIRE_TLS=true",
    "SMTP_IGNORE_TLS=false",
    "NODE_ENV=production",
    "TELEMETRY_ENABLED=false",
    "INVITE_ONLY_SIGNUP=true",
    "ALLOW_INTERNAL_IP_CONNECTIONS=false",
    "CORS_ALLOWED_ORIGINS=[\"https://${var.INFISICAL_APP_NAME}.${var.BASE_DOMAIN}\"]",
    "HOST=0.0.0.0",
    "JWT_AUTH_LIFETIME=15m",
    "JWT_REFRESH_LIFETIME=24h",
  ])

  infisical_dev_env = join("\n", [
    "ENCRYPTION_KEY=${var.INFISICAL_ENCRYPTION_KEY}",
    "AUTH_SECRET=${var.INFISICAL_AUTH_SECRET}",
    "DB_PASSWORD=${var.INFISICAL_DB_PASSWORD}",
    "DB_CONNECTION_URI=postgres://infisical:${var.INFISICAL_DB_PASSWORD}@postgres:5432/infisical",
    "REDIS_URL=redis://redis:6379",
    "SITE_URL=${local.infisical_dev_site_url}",
    "CLIENT_ID_GOOGLE_LOGIN=${var.INFISICAL_CLIENT_ID_GOOGLE_LOGIN}",
    "CLIENT_SECRET_GOOGLE_LOGIN=${var.INFISICAL_CLIENT_SECRET_GOOGLE_LOGIN}",
    "SMTP_HOST=${var.INFISICAL_SMTP_HOST}",
    "SMTP_PORT=${var.INFISICAL_SMTP_PORT}",
    "SMTP_USERNAME=${var.INFISICAL_SMTP_USERNAME}",
    "SMTP_PASSWORD=${var.INFISICAL_SMTP_PASSWORD}",
    "SMTP_FROM_ADDRESS=${var.INFISICAL_SMTP_FROM_ADDRESS}",
    "SMTP_FROM_NAME=${var.INFISICAL_SMTP_FROM_NAME}",
    "SMTP_REQUIRE_TLS=true",
    "SMTP_IGNORE_TLS=false",
    "NODE_ENV=production",
    "TELEMETRY_ENABLED=false",
    "INVITE_ONLY_SIGNUP=true",
    "ALLOW_INTERNAL_IP_CONNECTIONS=false",
    "CORS_ALLOWED_ORIGINS=[\"https://${var.INFISICAL_APP_NAME}-dev.${var.BASE_DOMAIN}\"]",
    "HOST=0.0.0.0",
    "JWT_AUTH_LIFETIME=15m",
    "JWT_REFRESH_LIFETIME=24h",
  ])
}

# ── Staging ──────────────────────────────────────────────────────────────

resource "dokploy_compose" "infisical_staging" {
  name             = var.INFISICAL_APP_NAME
  environment_id   = dokploy_environment.secrets_staging.id
  source_type      = "github"
  github_id        = "gLmK4q6_J6qZnJ1CtamVs"
  owner            = "CrystalMethod"
  repository       = "CtrlPlane"
  branch           = "main"
  compose_path     = "compose/platform/infisical/docker-compose.yml"
  auto_deploy      = true
  deploy_on_create = false
  env              = local.infisical_dev_env
  watch_paths      = ["compose/platform/infisical/**"]
}

resource "dokploy_domain" "infisical_staging" {
  compose_id       = dokploy_compose.infisical_staging.id
  service_name     = "backend"
  host             = "${var.INFISICAL_APP_NAME}-dev.${var.BASE_DOMAIN}"
  https            = false
  certificate_type = "none"
  port             = 8080
  path             = "/"
}

resource "null_resource" "infisical_deploy_staging" {
  depends_on = [dokploy_domain.infisical_staging]

  triggers = {
    compose_id    = dokploy_compose.infisical_staging.id
    refresh_token = dokploy_compose.infisical_staging.refresh_token
    branch        = dokploy_compose.infisical_staging.branch
  }

  provisioner "local-exec" {
    environment = {
      DOKPLOY_API_KEY = var.DOKPLOY_API_KEY
    }
    command = <<-EOT
      sleep 10
      curl -sf -k -X POST "${var.DOKPLOY_HOST}/deploy/compose/${self.triggers.refresh_token}" \
        -H "Content-Type: application/json" \
        -H "x-github-event: push" \
        -H "x-api-key: $DOKPLOY_API_KEY" \
        -d '{"commits": [{"modified": ["${dokploy_compose.infisical_staging.compose_path}"]}], "ref": "refs/heads/${self.triggers.branch}"}'
    EOT
  }
}

resource "null_resource" "infisical_bootstrap_staging" {
  depends_on = [null_resource.infisical_deploy_staging]

  triggers = {
    domain = local.infisical_dev_site_url
  }

  provisioner "local-exec" {
    command = join(" ", [
      "bash", "${path.module}/../../scripts/infisical-bootstrap.sh",
      "--domain", local.infisical_dev_site_url,
      "--email", var.INFISICAL_ADMIN_EMAIL,
      "--password", var.INFISICAL_ADMIN_PASSWORD,
      "--org", var.INFISICAL_ADMIN_ORGANIZATION,
    ])
  }
}

# ── Production ───────────────────────────────────────────────────────────

resource "dokploy_compose" "infisical_production" {
  name             = var.INFISICAL_APP_NAME
  environment_id   = dokploy_environment.secrets_production.id
  source_type      = "github"
  github_id        = "gLmK4q6_J6qZnJ1CtamVs"
  owner            = "CrystalMethod"
  repository       = "CtrlPlane"
  branch           = "prod"
  compose_path     = "compose/platform/infisical/docker-compose.yml"
  auto_deploy      = true
  deploy_on_create = false
  env              = local.infisical_env
  watch_paths      = ["compose/platform/infisical/**"]
}

resource "dokploy_domain" "infisical_production" {
  compose_id       = dokploy_compose.infisical_production.id
  service_name     = "backend"
  host             = "${var.INFISICAL_APP_NAME}.${var.BASE_DOMAIN}"
  https            = false
  certificate_type = "none"
  port             = 8080
  path             = "/"
}

resource "null_resource" "infisical_deploy_production" {
  depends_on = [dokploy_domain.infisical_production]

  triggers = {
    compose_id    = dokploy_compose.infisical_production.id
    refresh_token = dokploy_compose.infisical_production.refresh_token
    branch        = dokploy_compose.infisical_production.branch
  }

  provisioner "local-exec" {
    environment = {
      DOKPLOY_API_KEY = var.DOKPLOY_API_KEY
    }
    command = <<-EOT
      sleep 10
      curl -sf -k -X POST "${var.DOKPLOY_HOST}/deploy/compose/${self.triggers.refresh_token}" \
        -H "Content-Type: application/json" \
        -H "x-github-event: push" \
        -H "x-api-key: $DOKPLOY_API_KEY" \
        -d '{"commits": [{"modified": ["${dokploy_compose.infisical_production.compose_path}"]}], "ref": "refs/heads/${self.triggers.branch}"}'
    EOT
  }
}

resource "null_resource" "infisical_bootstrap_production" {
  depends_on = [null_resource.infisical_deploy_production]

  triggers = {
    domain = local.infisical_site_url
  }

  provisioner "local-exec" {
    command = join(" ", [
      "bash", "${path.module}/../../scripts/infisical-bootstrap.sh",
      "--domain", local.infisical_site_url,
      "--email", var.INFISICAL_ADMIN_EMAIL,
      "--password", var.INFISICAL_ADMIN_PASSWORD,
      "--org", var.INFISICAL_ADMIN_ORGANIZATION,
    ])
  }
}
