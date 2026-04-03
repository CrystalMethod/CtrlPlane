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

# Infisical compose environment variables
variable "INFISICAL_ENCRYPTION_KEY" {
  type      = string
  sensitive = true
}

variable "INFISICAL_AUTH_SECRET" {
  type      = string
  sensitive = true
}

variable "INFISICAL_DB_PASSWORD" {
  type      = string
  sensitive = true
}

variable "INFISICAL_SITE_URL" {
  type = string
}

variable "INFISICAL_CLIENT_ID_GOOGLE_LOGIN" {
  type      = string
  sensitive = true
}

variable "INFISICAL_CLIENT_SECRET_GOOGLE_LOGIN" {
  type      = string
  sensitive = true
}

variable "INFISICAL_SMTP_HOST" {
  type = string
}

variable "INFISICAL_SMTP_PORT" {
  type = string
}

variable "INFISICAL_SMTP_USERNAME" {
  type = string
}

variable "INFISICAL_SMTP_PASSWORD" {
  type      = string
  sensitive = true
}

variable "INFISICAL_SMTP_FROM_ADDRESS" {
  type = string
}

variable "INFISICAL_SMTP_FROM_NAME" {
  type = string
}
