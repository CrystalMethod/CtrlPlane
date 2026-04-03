#!/usr/bin/env bash
# Bootstrap orchestration script
# Brings up the entire homelab infrastructure from scratch.
# Idempotent: safe to re-run multiple times.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
TOFU_INFRA="$ROOT_DIR/tofu/00-infra"
TOFU_PLATFORM="$ROOT_DIR/tofu/01-platform"
TOFU_APPS="$ROOT_DIR/tofu/02-apps"

TFVARS="/tmp/bootstrap.tfvars"

trap 'rm -f "$TFVARS"' EXIT

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

generate_tfvars() {
  log "Generating terraform.tfvars from Fnox secrets..."
  fnox exec -- sh -c 'cat > '"$TFVARS"' <<EOF
CLOUDFLARE_ACCOUNT_ID = "$CLOUDFLARE_ACCOUNT_ID"
CLOUDFLARE_API_TOKEN = "$CLOUDFLARE_API_TOKEN"
CLOUDFLARE_R2_ACCESS_KEY_ID = "$CLOUDFLARE_R2_ACCESS_KEY_ID"
CLOUDFLARE_R2_SECRET_ACCESS_KEY = "$CLOUDFLARE_R2_SECRET_ACCESS_KEY"
CLOUDFLARE_TUNNEL_ID = "$CLOUDFLARE_TUNNEL_ID"
CLOUDFLARE_ZONE_ID = "$CLOUDFLARE_ZONE_ID"
DOKPLOY_API_KEY = "$DOKPLOY_API_KEY"
DOKPLOY_HOST = "${DOKPLOY_HOST:-}"
TOFU_STATE_PASSPHRASE = "$TOFU_STATE_PASSPHRASE"
EOF'
}

phase_infra() {
  log "=== Phase 1: Infrastructure (Cloudflare) ==="
  if [[ ! -d "$TOFU_INFRA" ]]; then
    log "SKIP: Infrastructure directory not found"
    return 0
  fi

  tofu -chdir="$TOFU_INFRA" init -backend=false -input=false
  tofu -chdir="$TOFU_INFRA" plan -var-file="$TFVARS" -input=false
  tofu -chdir="$TOFU_INFRA" apply -var-file="$TFVARS" -input=false -auto-approve
  log "Infrastructure phase complete"
}

phase_platform() {
  log "=== Phase 2: Platform (Dokploy) ==="
  if [[ ! -d "$TOFU_PLATFORM" ]]; then
    log "SKIP: Platform directory not found"
    return 0
  fi

  tofu -chdir="$TOFU_PLATFORM" init -backend=false -input=false
  tofu -chdir="$TOFU_PLATFORM" plan -var-file="$TFVARS" -input=false || {
    log "WARN: Platform plan failed (Dokploy may not be running yet)"
    return 0
  }
  tofu -chdir="$TOFU_PLATFORM" apply -var-file="$TFVARS" -input=false -auto-approve || {
    log "WARN: Platform apply failed (Dokploy may not be running yet)"
    return 0
  }
  log "Platform phase complete"
}

phase_apps() {
  log "=== Phase 3: Applications ==="
  if [[ ! -d "$TOFU_APPS" ]]; then
    log "SKIP: Apps directory not found"
    return 0
  fi

  tofu -chdir="$TOFU_APPS" init -backend=false -input=false
  tofu -chdir="$TOFU_APPS" plan -var-file="$TFVARS" -input=false || {
    log "WARN: Apps plan failed"
    return 0
  }
  tofu -chdir="$TOFU_APPS" apply -var-file="$TFVARS" -input=false -auto-approve || {
    log "WARN: Apps apply failed"
    return 0
  }
  log "Applications phase complete"
}

phase_seed_infisical() {
  log "=== Phase 4: Seed Infisical ==="
  if [[ -x "$SCRIPT_DIR/seed-infisical.sh" ]]; then
    if [[ -n "${INFISICAL_HOST:-}" && -n "${INFISICAL_API_TOKEN:-}" && -n "${INFISICAL_PROJECT_ID:-}" ]]; then
      "$SCRIPT_DIR/seed-infisical.sh"
    else
      log "SKIP: Infisical env vars not set (INFISICAL_HOST, INFISICAL_API_TOKEN, INFISICAL_PROJECT_ID)"
    fi
  else
    log "SKIP: seed-infisical.sh not found or not executable"
  fi
}

main() {
  log "=== Homelab Bootstrap ==="

  log "Verifying Fnox secrets..."
  fnox exec -- sh -c 'test -n "$CLOUDFLARE_API_TOKEN"' || {
    log "ERROR: Fnox secrets not accessible" >&2
    exit 1
  }

  generate_tfvars

  phase_infra
  phase_platform
  phase_apps
  phase_seed_infisical

  log "=== Bootstrap Complete ==="
}

main "$@"
