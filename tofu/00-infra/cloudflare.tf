resource "cloudflare_zone" "smb_tec" {
  account_id = var.CLOUDFLARE_ACCOUNT_ID
  zone       = "smb-tec.com"
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "smb_tec" {
  account_id = var.CLOUDFLARE_ACCOUNT_ID
  name       = "smb-tec.com"
  secret     = ""
}
