#!/usr/bin/env bash

# --- Configuration ---
ENDPOINT="https://ksvc-php-crud-hybrid-workload.apps.aws-cluster-01.sandbox650.opentlc.com"
CONCURRENCY=10
REQUESTS=200
# ----------------------

echo "Endpoint: $ENDPOINT"
echo "Total requests: $REQUESTS"
echo "Concurrency: $CONCURRENCY"
echo

PER_WORKER=$((REQUESTS / CONCURRENCY))
REMAINDER=$((REQUESTS % CONCURRENCY))

PIDS=()
for ((w=1; w<=CONCURRENCY; w++)); do
  EXTRA=0
  if [ $w -le $REMAINDER ]; then
    EXTRA=1
  fi
  COUNT=$((PER_WORKER + EXTRA))
  (
    for ((i=1; i<=COUNT; i++)); do
      CODE=$(curl -ks -o /dev/null -w "%{http_code}" "$ENDPOINT")
      echo "Worker $w: Request $i - HTTP $CODE"
    done
  ) &
  PIDS+=($!)
done

for PID in "${PIDS[@]}"; do
  wait $PID
done

echo "Load test complete."