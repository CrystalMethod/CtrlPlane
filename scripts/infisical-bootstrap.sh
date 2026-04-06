#!/usr/bin/env bash
set -euo pipefail

DOMAIN=""
EMAIL=""
PASSWORD=""
ORG=""
MAX_RETRIES=12
RETRY_DELAY=15

while [[ $# -gt 0 ]]; do
  case "$1" in
    --domain) DOMAIN="$2"; shift 2 ;;
    --email) EMAIL="$2"; shift 2 ;;
    --password) PASSWORD="$2"; shift 2 ;;
    --org) ORG="$2"; shift 2 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

for arg_name in DOMAIN EMAIL PASSWORD ORG; do
  if [[ -z "${!arg_name}" ]]; then
    echo "Missing required: --${arg_name,,}" >&2
    exit 1
  fi
done

wait_for_service() {
  for i in $(seq 1 "$MAX_RETRIES"); do
    if curl -sf -k "$DOMAIN/api/status" >/dev/null 2>&1; then
      return 0
    fi
    echo "Waiting for $DOMAIN (attempt $i/$MAX_RETRIES)..." >&2
    sleep "$RETRY_DELAY"
  done
  return 1
}

echo "Bootstrapping $DOMAIN..." >&2

if ! wait_for_service; then
  echo "Service at $DOMAIN did not become ready after $((MAX_RETRIES * RETRY_DELAY))s" >&2
  exit 1
fi

result=$(infisical bootstrap \
  --domain="$DOMAIN" \
  --email="$EMAIL" \
  --password="$PASSWORD" \
  --organization="$ORG" \
  --ignore-if-bootstrapped 2>&1) || true

if [ -z "$result" ]; then
  echo "Already bootstrapped: $DOMAIN" >&2
  exit 0
fi

org_id=$(echo "$result" | jq -r '.organization.id // empty' 2>/dev/null) || true
message=$(echo "$result" | jq -r '.message // empty' 2>/dev/null) || true

if [ -n "$org_id" ]; then
  echo "Bootstrapped $DOMAIN — org: $org_id" >&2
  exit 0
fi

if echo "$message" | grep -qi "already bootstrapped\|instance is already bootstrapped"; then
  echo "Already bootstrapped: $DOMAIN" >&2
  exit 0
fi

echo "Bootstrap failed for $DOMAIN" >&2
echo "Response: $result" >&2
exit 1
