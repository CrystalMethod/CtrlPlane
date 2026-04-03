provider "dokploy" {
  host    = var.DOKPLOY_HOST
  api_key = var.DOKPLOY_API_KEY
}

provider "cloudflare" {
  api_token = var.CLOUDFLARE_API_TOKEN
}

variable "CLOUDFLARE_API_TOKEN" {
  type      = string
  sensitive = true
}
