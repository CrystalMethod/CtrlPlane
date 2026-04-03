# OpenTofu native state encryption
# Encrypts .tfstate files at rest using AES-GCM
# Passphrase is injected via fn ox from fn ox.toml

encryption {
  key_provider "pbkdf2" "state_key" {
    passphrase = var.TOFU_STATE_PASSPHRASE
  }

  method "aes_gcm" "state_encryption" {
    keys = key_provider.pbkdf2.state_key
  }

  state {
    method   = method.aes_gcm.state_encryption
    enforce  = true
  }

  plan {
    method = method.aes_gcm.state_encryption
  }
}
