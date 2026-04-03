resource "dokploy_destination" "backups" {
  name              = "backups"
  bucket            = "backups"
  region            = ""
  endpoint          = "https://${var.CLOUDFLARE_ACCOUNT_ID}.r2.cloudflarestorage.com"
  access_key        = var.CLOUDFLARE_R2_ACCESS_KEY_ID
  secret_access_key = var.CLOUDFLARE_R2_SECRET_ACCESS_KEY
  storage_provider  = "Cloudflare"
}
