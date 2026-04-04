locals {
  infisical_env = join("\n", [
    "ENCRYPTION_KEY=${var.INFISICAL_ENCRYPTION_KEY}",
    "AUTH_SECRET=${var.INFISICAL_AUTH_SECRET}",
    "DB_CONNECTION_URI=postgres://infisical:${var.INFISICAL_DB_PASSWORD}@postgres:5432/infisical",
    "REDIS_URL=redis://redis:6379",
    "SITE_URL=${var.INFISICAL_SITE_URL}",
    "CLIENT_ID_GOOGLE_LOGIN=${var.INFISICAL_CLIENT_ID_GOOGLE_LOGIN}",
    "CLIENT_SECRET_GOOGLE_LOGIN=${var.INFISICAL_CLIENT_SECRET_GOOGLE_LOGIN}",
    "SMTP_HOST=${var.INFISICAL_SMTP_HOST}",
    "SMTP_PORT=${var.INFISICAL_SMTP_PORT}",
    "SMTP_USERNAME=${var.INFISICAL_SMTP_USERNAME}",
    "SMTP_PASSWORD=${var.INFISICAL_SMTP_PASSWORD}",
    "SMTP_FROM_ADDRESS=${var.INFISICAL_SMTP_FROM_ADDRESS}",
    "SMTP_FROM_NAME=${var.INFISICAL_SMTP_FROM_NAME}",
    "NODE_ENV=production",
    "TELEMETRY_ENABLED=false",
  ])
}

data "external" "infisical_bootstrap" {
  program = ["bash", "${path.module}/../../scripts/infisical-bootstrap.sh"]
  query = {
    domain       = var.INFISICAL_SITE_URL
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
  compose_path                = "homelab/infisical/docker-compose.yml"
  auto_deploy                 = true
  isolated_deployment         = true
  isolated_deployments_volume = true
  env                         = local.infisical_env
}

resource "dokploy_compose" "vaultwarden" {
  name           = "vaultwarden"
  environment_id = dokploy_environment.services_production.id

  lifecycle {
    ignore_changes = [
      auto_deploy,
      branch,
      isolated_deployment,
    ]
  }
}

resource "dokploy_compose" "paperless" {
  name           = "paperless"
  environment_id = dokploy_environment.services_production.id

  lifecycle {
    ignore_changes = [
      auto_deploy,
      branch,
      command,
      isolated_deployment,
    ]
  }
}

resource "dokploy_compose" "open_webui" {
  name           = "open-webui"
  environment_id = dokploy_environment.services_production.id

  lifecycle {
    ignore_changes = [
      auto_deploy,
      branch,
      isolated_deployment,
    ]
  }
}

resource "dokploy_compose" "cloudflared" {
  name           = "cloudflared"
  environment_id = dokploy_environment.infra_production.id

  lifecycle {
    ignore_changes = [
      auto_deploy,
      branch,
      isolated_deployment,
    ]
  }
}
