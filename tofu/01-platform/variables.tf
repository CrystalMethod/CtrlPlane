variable "DOKPLOY_HOST" {
  type      = string
  sensitive = true
}

variable "DOKPLOY_API_KEY" {
  type      = string
  sensitive = true
}

variable "CLOUDFLARE_ACCOUNT_ID" {
  type = string
}

variable "CLOUDFLARE_R2_ACCESS_KEY_ID" {
  type      = string
  sensitive = true
}

variable "CLOUDFLARE_R2_SECRET_ACCESS_KEY" {
  type      = string
  sensitive = true
}
