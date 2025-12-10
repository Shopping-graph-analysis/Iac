#!/bin/bash
set -e

echo "Starting Performance Quality Gate..."

# Default URL if not set
TARGET_URL=${TARGET_URL:-http://localhost:8080}

if ! command -v locust &> /dev/null; then
    echo "Locust is not installed. Please pip install locust."
    exit 1
fi

echo "Running Load Test against $TARGET_URL"
# Run headless for 1 minute with 10 users
locust -f workflow/performance_quality_gate/locustfile.py \
    --headless \
    -u 10 -r 2 \
    --run-time 1m \
    --host $TARGET_URL

echo "Performance Quality Gate Passed!"
