#!/usr/bin/env bash

set -Eeuo pipefail

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PUBLISHED_DASHBOARD="/var/www/html/status-v2.html"

echo "========================================"
echo " Monitoring cycle started: $(date)"
echo "========================================"

echo
echo "Running system health check..."
"$PROJECT_DIR/scripts/health-check.sh"

echo
echo "Generating Dashboard V2..."
"$PROJECT_DIR/scripts/generate-dashboard-v2.sh"

echo
echo "Publishing Dashboard V2..."
cp "$PROJECT_DIR/web/status-v2.html" "$PUBLISHED_DASHBOARD"

echo
echo "Dashboard published to:"
echo "$PUBLISHED_DASHBOARD"

echo
echo "Monitoring cycle completed: $(date)"
