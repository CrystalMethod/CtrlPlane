resource "cloudflare_zone" "smb_tec" {
  account = {
    id = var.CLOUDFLARE_ACCOUNT_ID
  }
  name = "smb-tec.com"
  type = "full"
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "smb_tec" {
  account_id = var.CLOUDFLARE_ACCOUNT_ID
  name       = "smb-tec.com"

  lifecycle {
    ignore_changes = all
  }
}

locals {
  tunnel_cname = "${cloudflare_zero_trust_tunnel_cloudflared.smb_tec.id}.cfargotunnel.com"
}

resource "cloudflare_dns_record" "smb_tec_cname_wildcard" {
  zone_id = cloudflare_zone.smb_tec.id
  name    = "*"
  content = local.tunnel_cname
  type    = "CNAME"
  proxied = true
  ttl     = 1

  lifecycle {
    prevent_destroy = true
  }
}

resource "cloudflare_dns_record" "smb_tec_cname_apex" {
  zone_id = cloudflare_zone.smb_tec.id
  name    = "@"
  content = local.tunnel_cname
  type    = "CNAME"
  proxied = true
  ttl     = 1

  lifecycle {
    prevent_destroy = true
  }
}

resource "cloudflare_dns_record" "smb_tec_mx_google_1" {
  zone_id  = cloudflare_zone.smb_tec.id
  name     = "smb-tec.com"
  content  = "aspmx.l.google.com"
  type     = "MX"
  priority = 1
  ttl      = 1

  lifecycle {
    prevent_destroy = true
  }
}

resource "cloudflare_dns_record" "smb_tec_mx_google_2" {
  zone_id  = cloudflare_zone.smb_tec.id
  name     = "smb-tec.com"
  content  = "alt1.aspmx.l.google.com"
  type     = "MX"
  priority = 5
  ttl      = 1

  lifecycle {
    prevent_destroy = true
  }
}

resource "cloudflare_dns_record" "smb_tec_mx_google_3" {
  zone_id  = cloudflare_zone.smb_tec.id
  name     = "smb-tec.com"
  content  = "alt2.aspmx.l.google.com"
  type     = "MX"
  priority = 5
  ttl      = 1

  lifecycle {
    prevent_destroy = true
  }
}

resource "cloudflare_dns_record" "smb_tec_mx_google_4" {
  zone_id  = cloudflare_zone.smb_tec.id
  name     = "smb-tec.com"
  content  = "alt3.aspmx.l.google.com"
  type     = "MX"
  priority = 10
  ttl      = 1

  lifecycle {
    prevent_destroy = true
  }
}

resource "cloudflare_dns_record" "smb_tec_mx_google_5" {
  zone_id  = cloudflare_zone.smb_tec.id
  name     = "smb-tec.com"
  content  = "alt4.aspmx.l.google.com"
  type     = "MX"
  priority = 10
  ttl      = 1

  lifecycle {
    prevent_destroy = true
  }
}

resource "cloudflare_dns_record" "smb_tec_txt_dkim" {
  zone_id = cloudflare_zone.smb_tec.id
  name    = "mail._domainkey.smb-tec.com"
  content = "\"v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAnavMThwm5i7lgYVL9J4JGPqM7UHWXC7Qxo2DvCUV80c3ZAw05hS7lp0Ten8HYNyhovSHD7i1zE1Rx7p38V80j0NJu9KF3AkL5Jm7euEwA9wb67sGQ6BHnOj7kQuwWsBR781qubiWh4xSR/BmtDw91CRoyQ/o3pncRnm\" \"QT3qKbG3J1dTrjcubL2Td4JC/7gtj1ai5KDbVpsjUDTjvb2njv3auSLJpu2JtOoBU0L3c9+6KdJQH4eBouKm3zY93nRxIjHC4MSZogXflCO1D/p7heHb9IOEbLEBb2qiIYsAALrmpFrN9Bd5E7D+hSzrsUYtEKHD3R4yUzRAJQkxHHfRH6wIDAQAB\""
  type    = "TXT"
  ttl     = 1

  lifecycle {
    prevent_destroy = true
  }
}

resource "cloudflare_dns_record" "smb_tec_txt_google_verify" {
  zone_id = cloudflare_zone.smb_tec.id
  name    = "smb-tec.com"
  content = "\"google-site-verification=ivza2mt25QbJvSO4h3VJqNVPWnP61XcUjksaw3eBhzw\""
  type    = "TXT"
  ttl     = 1

  lifecycle {
    prevent_destroy = true
  }
}

resource "cloudflare_r2_bucket" "backups" {
  account_id    = var.CLOUDFLARE_ACCOUNT_ID
  name          = "backups"
  location      = "eeur"
  storage_class = "Standard"

  lifecycle {
    prevent_destroy = true
  }
}
