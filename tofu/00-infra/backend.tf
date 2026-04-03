terraform {
  backend "s3" {
    bucket                      = "homelab-tf-state"
    key                         = "homelab/terraform.tfstate"
    region                      = "auto"
    access_key                  = var.CLOUDFLARE_R2_ACCESS_KEY_ID
    secret_key                  = var.CLOUDFLARE_R2_SECRET_ACCESS_KEY
    endpoints                   = { s3 = "https://${var.CLOUDFLARE_ACCOUNT_ID}.r2.cloudflarestorage.com" }
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
  }

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
    dokploy = {
      source  = "ahmedali6/dokploy"
      version = "~> 0.6"
    }
  }
}
