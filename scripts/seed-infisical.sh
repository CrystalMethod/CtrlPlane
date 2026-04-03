#!/usr/bin/env bash
# Seed Infisical with secrets from Fnox
# Reads decrypted Fnox secrets and pushes them into Infisical via REST API.
# Idempotent: safe to re-run (uses upsert semantics via POST→PATCH fallback).
set -euo pipefail

# Required env vars (injected via fnox or set manually):
#   INFISICAL_HOST       - Base URL of Infisical instance (e.g. https://infisical.example.com)
#   INFISICAL_API_TOKEN  - Personal access token or service token
#   INFISICAL_PROJECT_ID - The project/workspace ID to push secrets into
#   INFISICAL_ENVIRONMENT - Environment slug (default: "dev")

INFISICAL_ENVIRONMENT="${INFISICAL_ENVIRONMENT:-dev}"
INFISICAL_SECRET_PATH="${INFISICAL_SECRET_PATH:-/}"

if [[ -z "${INFISICAL_HOST:-}" ]]; then
  echo "ERROR: INFISICAL_HOST is not set" >&2
  exit 1
fi

if [[ -z "${INFISICAL_API_TOKEN:-}" ]]; then
  echo "ERROR: INFISICAL_API_TOKEN is not set" >&2
  exit 1
fi

if [[ -z "${INFISICAL_PROJECT_ID:-}" ]]; then
  echo "ERROR: INFISICAL_PROJECT_ID is not set" >&2
  exit 1
fi

# Strip trailing slash from host
INFISICAL_HOST="${INFISICAL_HOST%/}"

# Secrets to seed — add or remove as needed
SECRETS=(
  "CLOUDFLARE_API_TOKEN"
  "CLOUDFLARE_ACCOUNT_ID"
  "CLOUDFLARE_ZONE_ID"
  "CLOUDFLARE_TUNNEL_ID"
  "CLOUDFLARE_R2_ACCESS_KEY_ID"
  "CLOUDFLARE_R2_SECRET_ACCESS_KEY"
  "CLOUDFLARE_R2_API_TOKEN"
  "DOKPLOY_API_KEY"
  "TOFU_STATE_PASSPHRASE"
)

push_secret() {
  local name="$1"
  local value="$2"

  if [[ -z "$value" ]]; then
    echo "  SKIP: $name (empty value)"
    return 0
  fi

  # Try POST first (create), fall back to PATCH (update) for idempotency
  local http_code
  http_code=$(curl -s -o /dev/null -w "%{http_code}" \
    -X POST "${INFISICAL_HOST}/api/v4/secrets/${name}" \
    -H "Authorization: Bearer ${INFISICAL_API_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "{
      \"projectId\": \"${INFISICAL_PROJECT_ID}\",
      \"environment\": \"${INFISICAL_ENVIRONMENT}\",
      \"secretPath\": \"${INFISICAL_SECRET_PATH}\",
      \"secretValue\": $(printf '%s' "$value" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))')
    }" 2>/dev/null) || true

  if [[ "$http_code" == "200" ]]; then
    echo "  OK: $name (created)"
    return 0
  fi

  # If 400 (already exists), update via PATCH
  if [[ "$http_code" == "400" ]]; then
    http_code=$(curl -s -o /dev/null -w "%{http_code}" \
      -X PATCH "${INFISICAL_HOST}/api/v4/secrets/${name}" \
      -H "Authorization: Bearer ${INFISICAL_API_TOKEN}" \
      -H "Content-Type: application/json" \
      -d "{
        \"projectId\": \"${INFISICAL_PROJECT_ID}\",
        \"environment\": \"${INFISICAL_ENVIRONMENT}\",
        \"secretPath\": \"${INFISICAL_SECRET_PATH}\",
        \"secretValue\": $(printf '%s' "$value" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))')
      }" 2>/dev/null) || true

    if [[ "$http_code" == "200" ]]; then
      echo "  OK: $name (updated)"
      return 0
    fi
  fi

  echo "  FAIL: $name (HTTP $http_code)" >&2
  return 1
}

echo "=== Seeding Infisical ==="
echo "  Host:        ${INFISICAL_HOST}"
echo "  Project:     ${INFISICAL_PROJECT_ID}"
echo "  Environment: ${INFISICAL_ENVIRONMENT}"
echo "  Path:        ${INFISICAL_SECRET_PATH}"
echo "  Secrets:     ${#SECRETS[@]} to process"
echo ""

failed=0
for secret_name in "${SECRETS[@]}"; do
  # Get secret value from fnox
  secret_value=$(fnox exec -- sh -c "printenv ${secret_name}" 2>/dev/null) || true

  if ! push_secret "$secret_name" "$secret_value"; then
    ((failed++)) || true
  fi
done

echo ""
if [[ $failed -gt 0 ]]; then
  echo "Completed with $failed failure(s)" >&2
  exit 1
fi

echo "All secrets seeded successfully"
