terraform {
  # TODO: Switch to R2 backend once credentials are fixed
  # backend "s3" {
  #   bucket                      = "terraform"
  #   key                         = "homelab/terraform.tfstate"
  #   region                      = "auto"
  #   access_key                  = "0610c59312a3c4ef0299d3065d623cdb"
  #   secret_key                  = "7cabb1f9ccca36abf2b49d9714e545a8629bb176b16a566711b10ef425228e98"
  #   skip_credentials_validation = true
  #   skip_metadata_api_check     = true
  #   skip_region_validation      = true
  #   skip_requesting_account_id  = true
  #   endpoints = {
  #     s3 = "https://3f5370405376d390fff7ad291fc20ef9.r2.cloudflarestorage.com"
  #   }
  # }

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}
