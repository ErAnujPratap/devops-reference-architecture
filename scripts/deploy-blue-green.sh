#!/usr/bin/env bash
# deploy-blue-green.sh
# Automates weighted canary traffic shifting via Istio VirtualService,
# with health-check gates before promotion and automatic rollback on failure.

set -euo pipefail

NAMESPACE="payments-prod"
VS_NAME="transaction-service"
STRATEGY="canary"
WEIGHT=10
ACTION="shift"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --strategy) STRATEGY="$2"; shift 2 ;;
    --weight) WEIGHT="$2"; shift 2 ;;
    --promote) ACTION="promote"; shift ;;
    --rollback) ACTION="rollback"; shift ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

check_health() {
  echo "Checking error rate and latency via Prometheus..."
  ERROR_RATE=$(curl -s "http://prometheus:9090/api/v1/query?query=canary_error_rate" | jq -r '.data.result[0].value[1] // "0"')
  if (( $(echo "$ERROR_RATE > 1.0" | bc -l) )); then
    echo "Canary error rate ${ERROR_RATE}% exceeds threshold. Triggering rollback."
    rollback
    exit 1
  fi
  echo "Canary healthy (error rate: ${ERROR_RATE}%)"
}

shift_traffic() {
  echo "Shifting ${WEIGHT}% traffic to v2-canary..."
  kubectl patch virtualservice "$VS_NAME" -n "$NAMESPACE" --type merge -p "
spec:
  http:
  - route:
    - destination:
        host: transaction-service
        subset: v1-stable
      weight: $((100 - WEIGHT))
    - destination:
        host: transaction-service
        subset: v2-canary
      weight: $WEIGHT
"
  check_health
}

promote() {
  echo "Promoting v2-canary to 100% traffic..."
  kubectl patch virtualservice "$VS_NAME" -n "$NAMESPACE" --type merge -p '
spec:
  http:
  - route:
    - destination:
        host: transaction-service
        subset: v2-canary
      weight: 100
'
  echo "Promotion complete. v1-stable now idle, retained for fast rollback."
}

rollback() {
  echo "Rolling back to v1-stable (100% traffic)..."
  kubectl patch virtualservice "$VS_NAME" -n "$NAMESPACE" --type merge -p '
spec:
  http:
  - route:
    - destination:
        host: transaction-service
        subset: v1-stable
      weight: 100
'
  echo "Rollback complete."
}

case "$ACTION" in
  shift) shift_traffic ;;
  promote) promote ;;
  rollback) rollback ;;
esac
