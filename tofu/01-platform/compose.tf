locals {
  infisical_site_url     = "https://${var.INFISICAL_DOMAIN}"
  infisical_dev_site_url = "https://infisical-dev.${var.INFISICAL_DOMAIN_BASE}"

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
    "CORS_ALLOWED_ORIGINS=[\"https://${var.INFISICAL_DOMAIN}\"]",
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
    "CORS_ALLOWED_ORIGINS=[\"https://infisical-dev.${var.INFISICAL_DOMAIN_BASE}\"]",
    "HOST=0.0.0.0",
    "JWT_AUTH_LIFETIME=15m",
    "JWT_REFRESH_LIFETIME=24h",
  ])
}

data "external" "infisical_bootstrap" {
  program = ["bash", "${path.module}/../../scripts/infisical-bootstrap.sh"]
  query = {
    domain       = local.infisical_site_url
    email        = var.INFISICAL_ADMIN_EMAIL
    password     = var.INFISICAL_ADMIN_PASSWORD
    organization = var.INFISICAL_ADMIN_ORGANIZATION
  }
}

resource "dokploy_compose" "infisical" {
  name                        = "infisical"
  environment_id              = dokploy_environment.secrets_production.id
  source_type                 = "github"
  github_id                   = "gLmK4q6_J6qZnJ1CtamVs"
  owner                       = "CrystalMethod"
  repository                  = "CtrlPlane"
  branch                      = "main"
  compose_path                = "compose/platform/infisical/docker-compose.yml"
  auto_deploy                 = true
  isolated_deployment         = true
  isolated_deployments_volume = true
  env                         = local.infisical_env
}

resource "dokploy_domain" "infisical_production" {
  compose_id       = dokploy_compose.infisical.id
  service_name     = "backend"
  host             = var.INFISICAL_DOMAIN
  https            = false
  certificate_type = "none"
  port             = 8080
  path             = "/"
}
