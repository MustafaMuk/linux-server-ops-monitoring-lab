#!/usr/bin/env bash

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PUBLISHED_DASHBOARD="/var/www/html/status.html"

echo "========================================"
echo " Monitoring cycle started: $(date)"
echo "========================================"

"$PROJECT_DIR/scripts/health-check.sh"

echo
"$PROJECT_DIR/scripts/generate-dashboard.sh"

cp "$PROJECT_DIR/web/status.html" "$PUBLISHED_DASHBOARD"

echo
echo "Dashboard published to: $PUBLISHED_DASHBOARD"
echo "Monitoring cycle completed: $(date)"
