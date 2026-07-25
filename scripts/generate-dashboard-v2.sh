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
if [[ "$HTTP_CODE" == "200" ]]; then
    RESPONSE_HEALTH="$(classify_metric "$RESPONSE_MS" 300 1000)"
else
    RESPONSE_HEALTH="CRITICAL"
fi

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
status_class() {
    echo "$1" | tr '[:upper:]' '[:lower:]'
}

cap_percent() {
    local value="$1"

    if (( value > 100 )); then
        echo "100"
    elif (( value < 0 )); then
        echo "0"
    else
        echo "$value"
    fi
}

OVERALL_CLASS="$(status_class "$OVERALL_HEALTH")"
CPU_CLASS="$(status_class "$CPU_HEALTH")"
MEMORY_CLASS="$(status_class "$MEMORY_HEALTH")"
DISK_CLASS="$(status_class "$DISK_HEALTH")"
NGINX_CLASS="$(status_class "$NGINX_HEALTH")"
HTTP_CLASS="$(status_class "$HTTP_HEALTH")"
RESPONSE_CLASS="$(status_class "$RESPONSE_HEALTH")"

CPU_BAR_PERCENT="$(cap_percent "$CPU_LOAD_SCORE")"
MEMORY_BAR_PERCENT="$(cap_percent "$MEMORY_PERCENT")"
DISK_BAR_PERCENT="$(cap_percent "$DISK_PERCENT")"

if (( RESPONSE_MS >= 1000 )); then
    RESPONSE_BAR_PERCENT="100"
else
    RESPONSE_BAR_PERCENT="$((RESPONSE_MS / 10))"
fi

MONITORING_TIME="$(date '+%H:%M:%S')"

case "$OVERALL_HEALTH" in
    HEALTHY)
        STATUS_ICON="✓"
        STATUS_TITLE="All systems operational"
        STATUS_DESCRIPTION="Nginx is active and the HTTP endpoint is responding normally."
        ;;
    WARNING)
        STATUS_ICON="!"
        STATUS_TITLE="Performance warning detected"
        STATUS_DESCRIPTION="Services remain available, but one or more metrics require attention."
        ;;
    CRITICAL)
        STATUS_ICON="×"
        STATUS_TITLE="Service disruption detected"
        STATUS_DESCRIPTION="A critical service or availability check has failed."
        ;;
esac

cat > "$OUTPUT_FILE" <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="refresh" content="60">
    <title>Linux Server Operations Dashboard</title>
    <link rel="stylesheet" href="dashboard-v2.css">
</head>


<body>
    <main class="dashboard-shell">
        <header class="topbar">
            <div>
                <p class="eyebrow">Infrastructure Operations</p>

                <h1>Linux Server Operations Dashboard</h1>

                <p class="subtitle">
                    Live Linux and Nginx health monitoring generated with
                    Bash and automatically published through Nginx.
                </p>
            </div>

            <div class="header-meta">
                <span class="meta-pill">Ubuntu WSL2</span>
                <span class="meta-pill">Host: $HOST_NAME</span>
                <span class="meta-pill">Refresh: 15 minutes</span>
            </div>
        </header>

        <section class="status-banner $OVERALL_CLASS">
            <div class="status-main">
                <div class="status-icon">$STATUS_ICON</div>

                <div>
                    <p class="status-label">Overall server health</p>
                    <h2 class="status-title">$STATUS_TITLE</h2>

                    <p class="status-description">
                        $STATUS_DESCRIPTION
                    </p>
                </div>
            </div>

            <div class="status-time">
                Last evaluated<br>
                <strong>$LAST_UPDATED</strong>
            </div>
        </section>

        <section class="section">
            <div class="section-heading">
                <div>
                    <h2 class="section-title">System metrics</h2>
                    <p class="section-note">
                        Current operating-system and service measurements
                    </p>
                </div>
            </div>

            <div class="metric-grid">
                <article class="metric-card">
                    <div class="metric-header">
                        <span class="metric-label">CPU Load</span>

                        <span class="health-chip $CPU_CLASS">
                            $CPU_HEALTH
                        </span>
                    </div>

                    <div class="metric-value">$CPU_LOAD_PERCENT%</div>

                    <div class="metric-detail">
                        Load average $LOAD_1_MINUTE across $CPU_CORES cores
                    </div>

                    <div class="progress-track">
                        <div
                            class="progress-bar $CPU_CLASS"
                            style="width: $CPU_BAR_PERCENT%;"
                        ></div>
                    </div>
                </article>

                <article class="metric-card">
                    <div class="metric-header">
                        <span class="metric-label">Memory Usage</span>

                        <span class="health-chip $MEMORY_CLASS">
                            $MEMORY_HEALTH
                        </span>
                    </div>

                    <div class="metric-value">$MEMORY_PERCENT%</div>

                    <div class="metric-detail">$MEMORY_USAGE</div>

                    <div class="progress-track">
                        <div
                            class="progress-bar $MEMORY_CLASS"
                            style="width: $MEMORY_BAR_PERCENT%;"
                        ></div>
                    </div>
                </article>

                <article class="metric-card">
                    <div class="metric-header">
                        <span class="metric-label">Disk Usage</span>

                        <span class="health-chip $DISK_CLASS">
                            $DISK_HEALTH
                        </span>
                    </div>

                    <div class="metric-value">$DISK_PERCENT%</div>

                    <div class="metric-detail">$DISK_USAGE</div>

                    <div class="progress-track">
                        <div
                            class="progress-bar $DISK_CLASS"
                            style="width: $DISK_BAR_PERCENT%;"
                        ></div>
                    </div>
                </article>

                <article class="metric-card">
                    <div class="metric-header">
                        <span class="metric-label">System Uptime</span>
                        <span class="health-chip healthy">ONLINE</span>
                    </div>

                    <div class="metric-value">$SYSTEM_UPTIME</div>

                    <div class="metric-detail">
                        Hostname: $HOST_NAME
                    </div>
                </article>

                <article class="metric-card">
                    <div class="metric-header">
                        <span class="metric-label">Running Processes</span>
                        <span class="health-chip healthy">LIVE</span>
                    </div>

                    <div class="metric-value">$PROCESS_COUNT</div>

                    <div class="metric-detail">
                        Current Linux process count
                    </div>
                </article>

                <article class="metric-card">
                    <div class="metric-header">
                        <span class="metric-label">Nginx Workers</span>

                        <span class="health-chip $NGINX_CLASS">
                            $NGINX_HEALTH
                        </span>
                    </div>

                    <div class="metric-value">$NGINX_WORKERS</div>

                    <div class="metric-detail">
                        Active Nginx worker processes
                    </div>
                </article>

                <article class="metric-card">
                    <div class="metric-header">
                        <span class="metric-label">HTTP Response</span>

                        <span class="health-chip $HTTP_CLASS">
                            $HTTP_HEALTH
                        </span>
                    </div>

                    <div class="metric-value">$HTTP_CODE</div>

                    <div class="metric-detail">
                        Response from http://localhost
                    </div>
                </article>

                <article class="metric-card">
                    <div class="metric-header">
                        <span class="metric-label">Response Time</span>

                        <span class="health-chip $RESPONSE_CLASS">
                            $RESPONSE_HEALTH
                        </span>
                    </div>

                    <div class="metric-value">${RESPONSE_MS} ms</div>

                    <div class="metric-detail">
                        Total HTTP request duration
                    </div>

                    <div class="progress-track">
                        <div
                            class="progress-bar $RESPONSE_CLASS"
                            style="width: $RESPONSE_BAR_PERCENT%;"
                        ></div>
                    </div>
                </article>
            </div>
        </section>

        <section class="section">
            <div class="section-heading">
                <div>
                    <h2 class="section-title">Operational checks</h2>

                    <p class="section-note">
                        Service, availability and capacity verification
                    </p>
                </div>
            </div>

            <div class="operations-grid">
                <div class="check-list">
                    <div class="check-row">
                        <span class="check-name">Nginx service</span>
                        <span class="check-result">$NGINX_STATUS</span>

                        <span class="status-indicator">
                            <span class="status-dot $NGINX_CLASS"></span>
                            $NGINX_HEALTH
                        </span>
                    </div>

                    <div class="check-row">
                        <span class="check-name">HTTP endpoint</span>
                        <span class="check-result">HTTP $HTTP_CODE</span>

                        <span class="status-indicator">
                            <span class="status-dot $HTTP_CLASS"></span>
                            $HTTP_HEALTH
                        </span>
                    </div>

                    <div class="check-row">
                        <span class="check-name">Response latency</span>
                        <span class="check-result">${RESPONSE_MS} ms</span>

                        <span class="status-indicator">
                            <span class="status-dot $RESPONSE_CLASS"></span>
                            $RESPONSE_HEALTH
                        </span>
                    </div>

                    <div class="check-row">
                        <span class="check-name">Memory capacity</span>
                        <span class="check-result">$MEMORY_PERCENT% used</span>

                        <span class="status-indicator">
                            <span class="status-dot $MEMORY_CLASS"></span>
                            $MEMORY_HEALTH
                        </span>
                    </div>

                    <div class="check-row">
                        <span class="check-name">Disk capacity</span>
                        <span class="check-result">$DISK_PERCENT% used</span>

                        <span class="status-indicator">
                            <span class="status-dot $DISK_CLASS"></span>
                            $DISK_HEALTH
                        </span>
                    </div>
                </div>

                <div class="timeline">
                    <div class="timeline-item">
                        <span class="timeline-time">$MONITORING_TIME</span>
                        <span class="timeline-message">
                            Monitoring cycle collected Linux system metrics.
                        </span>
                    </div>

                    <div class="timeline-item">
                        <span class="timeline-time">$MONITORING_TIME</span>
                        <span class="timeline-message">
                            Nginx service returned $NGINX_STATUS.
                        </span>
                    </div>

                    <div class="timeline-item">
                        <span class="timeline-time">$MONITORING_TIME</span>
                        <span class="timeline-message">
                            HTTP endpoint returned status $HTTP_CODE in
                            ${RESPONSE_MS} ms.
                        </span>
                    </div>

                    <div class="timeline-item">
                        <span class="timeline-time">$MONITORING_TIME</span>
                        <span class="timeline-message">
                            Dashboard regenerated successfully.
                        </span>
                    </div>
                </div>
            </div>
        </section>

        <footer class="dashboard-footer">
            <div>
                Managed by <strong>Mustafa Mukhtar</strong><br>
                Generated as part of the Linux Server Operations Lab
            </div>

            <div class="stack-list">
                <span class="stack-item">Ubuntu</span>
                <span class="stack-item">Nginx</span>
                <span class="stack-item">Bash</span>
                <span class="stack-item">systemd</span>
                <span class="stack-item">cron</span>
                <span class="stack-item">Git</span>
            </div>
        </footer>
    </main>
</body>
</html>
EOF

echo
echo "Dashboard V2 generated at: $OUTPUT_FILE"
