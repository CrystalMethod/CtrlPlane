variable "CLOUDFLARE_API_TOKEN" {
  type      = string
  sensitive = true
}

variable "CLOUDFLARE_R2_ACCESS_KEY_ID" {
  type      = string
  sensitive = true
}

variable "CLOUDFLARE_R2_SECRET_ACCESS_KEY" {
  type      = string
  sensitive = true
}

variable "CLOUDFLARE_ZONE_ID" {
  type = string
}

variable "CLOUDFLARE_TUNNEL_ID" {
  type = string
}

variable "CLOUDFLARE_ACCOUNT_ID" {
  type = string
}

variable "TOFU_STATE_PASSPHRASE" {
  type      = string
  sensitive = true
}
