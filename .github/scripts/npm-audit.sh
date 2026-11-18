#!/usr/bin/env bash
# npm audit at high severity, run from a package folder. Fails on real findings,
# but an unavailable audit service only warns.
for i in 1 2 3; do
  out=$(npm audit --audit-level=high "$@" 2>&1) && { echo "$out"; exit 0; }
  echo "$out"
  # npm exits 1 both for real vulns and for endpoint errors; tell them apart by the message
  if ! echo "$out" | grep -qiE 'audit endpoint returned an error|Service Unavailable|Bad Request|ECONNRESET|ETIMEDOUT'; then
    exit 1  # genuine vulnerabilities at/above high
  fi
  echo "audit endpoint error (attempt $i), retrying in 30s..."
  sleep 30
done
echo "::warning::npm audit endpoint unavailable after 3 attempts, skipping"
