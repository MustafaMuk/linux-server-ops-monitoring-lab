#!/usr/bin/env bash

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_FILE="$PROJECT_DIR/web/status.html"

HOST_NAME="$(hostname)"
CURRENT_USER="$(whoami)"
UPTIME="$(uptime -p)"
DISK_USAGE="$(df -h / | awk 'NR==2 {print $5}')"
MEMORY_USAGE="$(free -h | awk '/^Mem:/ {print $3 " used out of " $2}')"
NGINX_STATUS="$(systemctl is-active nginx)"
HTTP_CODE="$(curl -s -o /dev/null -w "%{http_code}" http://localhost || true)"
LAST_UPDATED="$(date)"

if [[ "$NGINX_STATUS" == "active" && "$HTTP_CODE" == "200" ]]; then
    HEALTH_STATUS="HEALTHY"
    STATUS_CLASS="healthy"
else
    HEALTH_STATUS="UNHEALTHY"
    STATUS_CLASS="unhealthy"
fi

cat > "$OUTPUT_FILE" <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Linux Server Health Dashboard</title>

    <style>
        body {
            background: #111827;
            color: #e5e7eb;
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 40px;
        }

        .container {
            max-width: 900px;
            margin: auto;
        }

        h1 {
            margin-bottom: 5px;
        }

        .subtitle {
            color: #9ca3af;
            margin-bottom: 30px;
        }

        .status {
            display: inline-block;
            padding: 10px 18px;
            border-radius: 8px;
            font-weight: bold;
            margin-bottom: 25px;
        }

        .healthy {
            background: #065f46;
            color: #d1fae5;
        }

        .unhealthy {
            background: #991b1b;
            color: #fee2e2;
        }

        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
            gap: 16px;
        }

        .card {
            background: #1f2937;
            padding: 20px;
            border-radius: 10px;
        }

        .label {
            color: #9ca3af;
            font-size: 14px;
        }

        .value {
            font-size: 20px;
            margin-top: 8px;
        }

        footer {
            color: #9ca3af;
            margin-top: 30px;
            font-size: 14px;
        }
    </style>
</head>

<body>
    <div class="container">
        <h1>Linux Server Operations Dashboard</h1>
        <p class="subtitle">Nginx and system health monitoring</p>

        <div class="status $STATUS_CLASS">
            $HEALTH_STATUS
        </div>

        <div class="grid">
            <div class="card">
                <div class="label">Hostname</div>
                <div class="value">$HOST_NAME</div>
            </div>

            <div class="card">
                <div class="label">Current User</div>
                <div class="value">$CURRENT_USER</div>
            </div>

            <div class="card">
                <div class="label">System Uptime</div>
                <div class="value">$UPTIME</div>
            </div>

            <div class="card">
                <div class="label">Disk Usage</div>
                <div class="value">$DISK_USAGE</div>
            </div>

            <div class="card">
                <div class="label">Memory Usage</div>
                <div class="value">$MEMORY_USAGE</div>
            </div>

            <div class="card">
                <div class="label">Nginx Service</div>
                <div class="value">$NGINX_STATUS</div>
            </div>

            <div class="card">
                <div class="label">HTTP Response</div>
                <div class="value">$HTTP_CODE</div>
            </div>
        </div>

        <footer>
            Last updated: $LAST_UPDATED<br>
            Managed by Mustafa Mukhtar
        </footer>
    </div>
</body>
</html>
EOF

echo "Dashboard generated at: $OUTPUT_FILE"
