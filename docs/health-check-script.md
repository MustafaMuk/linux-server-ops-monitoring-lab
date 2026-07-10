# Bash Health-Check Script

## Purpose

The health-check script collects basic system information and checks whether the Nginx web server is operating correctly.

The script is stored at:

scripts/health-check.sh

The generated report is stored at:

reports/health-report.txt

## Checks Performed

The script checks:

- Current date and time
- Hostname
- Current Linux user
- System uptime
- Disk usage
- Memory usage
- Nginx service status
- HTTP response from localhost

## Nginx Service Check

The script uses:

systemctl is-active --quiet nginx

If Nginx is running, the script reports:

ACTIVE

If Nginx is stopped, the script reports:

INACTIVE

## HTTP Health Check

The script uses curl to request localhost and capture only the HTTP status code.

A response code of 200 means the web server responded successfully.

The script reports:

HEALTHY - localhost returned HTTP 200

Any other response is reported as unhealthy.

## Variables

PROJECT_DIR stores the main project directory.

REPORT_DIR stores the reports directory path.

REPORT_FILE stores the complete health-report file path.

HTTP_CODE stores the response code returned by localhost.

## Output Redirection

The script uses tee to display the report in the terminal while also writing it to:

reports/health-report.txt

## Why This Matters For DevOps

Health-check scripts help engineers inspect systems, verify services, detect failures, and collect useful troubleshooting information.

This script provides a simple example of automated service monitoring using Bash, systemctl, curl, and Linux system commands.
