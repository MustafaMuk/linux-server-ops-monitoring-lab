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

CPU_LOAD_PERCENT="$(
    awk -v load_value="$LOAD_1_MINUTE" -v cores="$CPU_CORES" \
        'BEGIN {
            if (cores > 0) {
                printf "%.1f", (load_value / cores) * 100
            } else {
                print "0.0"
            }
        }'
)"

CPU_LOAD_SCORE="$(
    awk -v load_value="$LOAD_1_MINUTE" -v cores="$CPU_CORES" \
        'BEGIN {
            if (cores > 0) {
                printf "%.0f", (load_value / cores) * 100
            } else {
                print "0"
            }
        }'
)"

PROCESS_COUNT="$(ps -e --no-headers | wc -l | xargs)"
NGINX_WORKERS="$(pgrep -fc 'nginx: worker process' || true)"

DISK_PERCENT="$(df -P / | awk 'NR==2 {gsub("%", "", $5); print $5}')"
DISK_USAGE="$(df -hP / | awk 'NR==2 {print $3 " used out of " $2}')"

MEMORY_TOTAL_BYTES="$(free -b | awk '/^Mem:/ {print $2}')"
MEMORY_USED_BYTES="$(free -b | awk '/^Mem:/ {print $3}')"
MEMORY_PERCENT="$((MEMORY_USED_BYTES * 100 / MEMORY_TOTAL_BYTES))"
MEMORY_USAGE="$(free -h | awk '/^Mem:/ {print $3 " used out of " $2}')"

NGINX_STATUS="$(systemctl is-active nginx 2>/dev/null || true)"

if CURL_RESULT="$(
    curl \
        --silent \
        --output /dev/null \
        --write-out '%{http_code} %{time_total}' \
        --max-time 5 \
        http://localhost
)"; then
    read -r HTTP_CODE RESPONSE_SECONDS <<< "$CURL_RESULT"
else
    HTTP_CODE="000"
    RESPONSE_SECONDS="0"
fi

RESPONSE_MS="$(
    awk -v seconds="$RESPONSE_SECONDS" \
        'BEGIN { printf "%.0f", seconds * 1000 }'
)"

classify_metric() {
    local value="$1"
    local warning_threshold="$2"
    local critical_threshold="$3"

    if (( value >= critical_threshold )); then
        echo "CRITICAL"
    elif (( value >= warning_threshold )); then
        echo "WARNING"
    else
        echo "HEALTHY"
    fi
}

CPU_HEALTH="$(classify_metric "$CPU_LOAD_SCORE" 70 90)"
MEMORY_HEALTH="$(classify_metric "$MEMORY_PERCENT" 75 90)"
DISK_HEALTH="$(classify_metric "$DISK_PERCENT" 75 90)"
RESPONSE_HEALTH="$(classify_metric "$RESPONSE_MS" 300 1000)"

if [[ "$NGINX_STATUS" == "active" ]]; then
    NGINX_HEALTH="HEALTHY"
else
    NGINX_HEALTH="CRITICAL"
fi

if [[ "$HTTP_CODE" == "200" ]]; then
    HTTP_HEALTH="HEALTHY"
else
    HTTP_HEALTH="CRITICAL"
fi

OVERALL_HEALTH="HEALTHY"

for STATUS in \
    "$CPU_HEALTH" \
    "$MEMORY_HEALTH" \
    "$DISK_HEALTH" \
    "$RESPONSE_HEALTH" \
    "$NGINX_HEALTH" \
    "$HTTP_HEALTH"
do
    if [[ "$STATUS" == "CRITICAL" ]]; then
        OVERALL_HEALTH="CRITICAL"
        break
    fi

    if [[ "$STATUS" == "WARNING" ]]; then
        OVERALL_HEALTH="WARNING"
    fi
done

echo "========================================"
echo " Dashboard V2 Health Classification"
echo "========================================"
echo
echo "Overall health:     $OVERALL_HEALTH"
echo
echo "Hostname:           $HOST_NAME"
echo "Current user:       $CURRENT_USER"
echo "System uptime:      $SYSTEM_UPTIME"
echo
echo "CPU cores:          $CPU_CORES"
echo "1-minute load:      $LOAD_1_MINUTE"
echo "CPU load estimate:  $CPU_LOAD_PERCENT% [$CPU_HEALTH]"
echo
echo "Running processes:  $PROCESS_COUNT"
echo "Nginx workers:      $NGINX_WORKERS"
echo
echo "Disk usage:         $DISK_USAGE ($DISK_PERCENT%) [$DISK_HEALTH]"
echo "Memory usage:       $MEMORY_USAGE ($MEMORY_PERCENT%) [$MEMORY_HEALTH]"
echo
echo "Nginx service:      $NGINX_STATUS [$NGINX_HEALTH]"
echo "HTTP response:      $HTTP_CODE [$HTTP_HEALTH]"
echo "Response time:      ${RESPONSE_MS} ms [$RESPONSE_HEALTH]"
echo
echo "Last updated:       $LAST_UPDATED"
echo "Future output:      $OUTPUT_FILE"
