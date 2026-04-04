#!/usr/bin/env bash
# Infisical bootstrap wrapper for terraform data "external"
# Reads query JSON from stdin, runs infisical bootstrap, returns result JSON.
set -euo pipefail

query=$(cat)
domain=$(echo "$query" | jq -r '.domain')
email=$(echo "$query" | jq -r '.email')
password=$(echo "$query" | jq -r '.password')
organization=$(echo "$query" | jq -r '.organization')

result=$(infisical bootstrap \
  --domain="$domain" \
  --email="$email" \
  --password="$password" \
  --organization="$organization" \
  --ignore-if-bootstrapped 2>&1) || true

org_id=$(echo "$result" | jq -r '.organization.id // empty' 2>/dev/null) || true

if [ -n "$org_id" ]; then
  echo "$result" | jq '{org_id: .organization.id, user_id: .user.id, bootstrapped: "true"}'
else
  echo '{"org_id": "", "user_id": "", "bootstrapped": "false"}'
fi
