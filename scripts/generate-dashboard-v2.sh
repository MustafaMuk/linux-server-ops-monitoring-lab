#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_FILE="$PROJECT_DIR/web/status-v2.html"

HOST_NAME="$(hostname)"
CURRENT_USER="$(whoami)"
SYSTEM_UPTIME="$(uptime -p)"
LAST_UPDATED="$(date '+%d %b %Y, %H:%M:%S %Z')"

CPU_CORES="$(nproc)"
LOAD_1_MINUTE="$(awk '{print $1}' /proc/loadavg)"
PROCESS_COUNT="$(ps -e --no-headers | wc -l | xargs)"
NGINX_WORKERS="$(pgrep -fc 'nginx: worker process' || true)"

DISK_PERCENT="$(df -P / | awk 'NR==2 {gsub("%", "", $5); print $5}')"
DISK_USAGE="$(df -hP / | awk 'NR==2 {print $3 " used out of " $2}')"

MEMORY_TOTAL_BYTES="$(free -b | awk '/^Mem:/ {print $2}')"
MEMORY_USED_BYTES="$(free -b | awk '/^Mem:/ {print $3}')"
MEMORY_PERCENT="$((MEMORY_USED_BYTES * 100 / MEMORY_TOTAL_BYTES))"
MEMORY_USAGE="$(free -h | awk '/^Mem:/ {print $3 " used out of " $2}')"

NGINX_STATUS="$(systemctl is-active nginx 2>/dev/null || true)"

CURL_RESULT="$(
    curl \
        --silent \
        --show-error \
        --output /dev/null \
        --write-out '%{http_code} %{time_total}' \
        --max-time 5 \
        http://localhost \
        2>/dev/null || printf '000 0'
)"

read -r HTTP_CODE RESPONSE_SECONDS <<< "$CURL_RESULT"

RESPONSE_MS="$(
    awk -v seconds="$RESPONSE_SECONDS" \
        'BEGIN { printf "%.0f", seconds * 1000 }'
)"

echo "========================================"
echo " Dashboard V2 Metric Collection"
echo "========================================"
echo
echo "Hostname:          $HOST_NAME"
echo "Current user:      $CURRENT_USER"
echo "System uptime:     $SYSTEM_UPTIME"
echo "CPU cores:         $CPU_CORES"
echo "1-minute load:     $LOAD_1_MINUTE"
echo "Running processes: $PROCESS_COUNT"
echo "Nginx workers:     $NGINX_WORKERS"
echo "Disk usage:        $DISK_USAGE ($DISK_PERCENT%)"
echo "Memory usage:      $MEMORY_USAGE ($MEMORY_PERCENT%)"
echo "Nginx service:     $NGINX_STATUS"
echo "HTTP response:     $HTTP_CODE"
echo "Response time:     ${RESPONSE_MS} ms"
echo "Last updated:      $LAST_UPDATED"
echo
echo "Future output:     $OUTPUT_FILE"
