variable "compose_id" {
  type = string
}

variable "refresh_token" {
  type      = string
  sensitive = true
}

variable "branch" {
  type = string
}

variable "compose_path" {
  type = string
}

variable "dokploy_host" {
  type = string
}

variable "dokploy_api_key" {
  type      = string
  sensitive = true
}

resource "null_resource" "this" {
  triggers = {
    compose_id    = var.compose_id
    refresh_token = var.refresh_token
    branch        = var.branch
  }

  provisioner "local-exec" {
    environment = {
      DOKPLOY_API_KEY = var.dokploy_api_key
    }
    command = <<-EOT
      sleep 10
      curl -sf -k -X POST "${var.dokploy_host}/deploy/compose/${self.triggers.refresh_token}" \
        -H "Content-Type: application/json" \
        -H "x-github-event: push" \
        -H "x-api-key: $DOKPLOY_API_KEY" \
        -d '{"commits": [{"modified": ["${var.compose_path}"]}], "ref": "refs/heads/${self.triggers.branch}"}'
    EOT
  }
}
