terraform {
  backend "s3" {
    bucket                      = "terraform"
    key                         = "homelab/platform/state"
    region                      = "auto"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    use_path_style              = true
    use_lockfile                = true
    endpoints = {
      s3 = "https://3f5370405376d390fff7ad291fc20ef9.r2.cloudflarestorage.com"
    }
  }

  required_providers {
    dokploy = {
      source = "registry.terraform.io/ahmedali6/dokploy"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }
}
