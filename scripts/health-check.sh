#!/usr/bin/env bash

# Find the main project directory, regardless of where the script is run from.
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

REPORT_DIR="$PROJECT_DIR/reports"
REPORT_FILE="$REPORT_DIR/health-report.txt"

# Ensure the reports directory exists.
mkdir -p "$REPORT_DIR"

# Check the HTTP response without printing the webpage.
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost || true)

{
    echo "========================================"
    echo " Linux Server Health Report"
    echo "========================================"
    echo

    echo "Date and time:"
    date
    echo

    echo "Hostname:"
    hostname
    echo

    echo "Current user:"
    whoami
    echo

    echo "System uptime:"
    uptime -p
    echo

    echo "Disk usage:"
    df -h /
    echo

    echo "Memory usage:"
    free -h
    echo

    echo "Nginx service status:"
    if systemctl is-active --quiet nginx; then
        echo "ACTIVE"
    else
        echo "INACTIVE"
    fi
    echo

    echo "Nginx HTTP check:"
    if [[ "$HTTP_CODE" == "200" ]]; then
        echo "HEALTHY - localhost returned HTTP 200"
    else
        echo "UNHEALTHY - localhost returned HTTP $HTTP_CODE"
    fi
    echo

    echo "Report location:"
    echo "$REPORT_FILE"
} | tee "$REPORT_FILE"
