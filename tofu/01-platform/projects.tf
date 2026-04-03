resource "dokploy_project" "secrets" {
  name        = "secrets"
  description = "Secrets management"
}

resource "dokploy_environment" "secrets_production" {
  project_id = dokploy_project.secrets.id
  name       = "production"

  lifecycle {
    ignore_changes = [project_id]
  }
}

resource "dokploy_project" "services" {
  name        = "services"
  description = ""
}

resource "dokploy_environment" "services_production" {
  project_id = dokploy_project.services.id
  name       = "production"

  lifecycle {
    ignore_changes = [project_id]
  }
}

resource "dokploy_project" "infra" {
  name        = "infra"
  description = ""
}

resource "dokploy_environment" "infra_production" {
  project_id = dokploy_project.infra.id
  name       = "production"

  lifecycle {
    ignore_changes = [project_id]
  }
}
