#!/usr/bin/env bash
set -euo pipefail

BASE_URL="http://127.0.0.1"

check_health() {
  local name="$1"
  local port="$2"

  echo "Checking ${name}..."

  curl --fail --silent --show-error \
    --retry 10 \
    --retry-delay 1 \
    --retry-connrefused \
    "${BASE_URL}:${port}/health"

  echo
  echo "PASS: ${name}"
}

check_health "admin-auth" 12200
check_health "admin-gateway" 12100
check_health "admin-bff" 12000

echo "Checking admin-front..."

curl --fail --silent --show-error \
  --retry 10 \
  --retry-delay 1 \
  --retry-connrefused \
  --output /dev/null \
  "${BASE_URL}:11000/"

echo "PASS: admin-front"
echo "All HTTP smoke checks passed."
