# dokploy-deploy-trigger

Triggers a Dokploy compose deployment via webhook after domains are attached.

## Usage

```hcl
module "app_deploy_staging" {
  source          = "../modules/dokploy-deploy-trigger"
  compose_id      = dokploy_compose.app_staging.id
  refresh_token   = dokploy_compose.app_staging.refresh_token
  branch          = dokploy_compose.app_staging.branch
  compose_path    = dokploy_compose.app_staging.compose_path
  dokploy_host    = var.DOKPLOY_HOST
  dokploy_api_key = var.DOKPLOY_API_KEY
}
```

## Why this exists

Dokploy's `deploy_on_create = true` deploys the compose before domains are attached, resulting in containers without Traefik labels. This module triggers deployment via webhook after the domain resource exists.

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| `compose_id` | Dokploy compose resource ID | `string` | yes |
| `refresh_token` | Compose webhook refresh token | `string` | yes |
| `branch` | Git branch name | `string` | yes |
| `compose_path` | Path to compose file in repo | `string` | yes |
| `dokploy_host` | Dokploy API base URL | `string` | yes |
| `dokploy_api_key` | Dokploy API key | `string` | yes |

## Outputs

None. Use `module.<name>.null_resource.this` in `depends_on` for downstream resources.
