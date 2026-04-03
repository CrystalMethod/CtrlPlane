resource "dokploy_compose" "infisical" {
  name           = "infisical"
  environment_id = dokploy_environment.secrets_production.id

  lifecycle {
    ignore_changes = [
      auto_deploy,
      branch,
      compose_path,
      environment_id,
      github_id,
      isolated_deployment,
      owner,
      repository,
    ]
  }
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
