# Automated Linux Server Dashboard

## Purpose

This project generates and publishes an HTML dashboard showing the current health of the Linux system and Nginx web server.

The dashboard is generated using Bash and served through Nginx.

## Dashboard Generator

The dashboard generator is stored at:

scripts/generate-dashboard.sh

It collects:

- Hostname
- Current user
- System uptime
- Disk usage
- Memory usage
- Nginx service status
- HTTP response code
- Last update time

The script uses conditional logic to classify the server as:

- HEALTHY
- UNHEALTHY

## Monitoring Cycle

The complete monitoring workflow is controlled by:

scripts/run-monitoring-cycle.sh

This script:

1. Runs the system health check
2. Generates the HTML dashboard
3. Copies the dashboard into the Nginx web directory
4. Records the completion time

The published dashboard is stored at:

/var/www/html/status.html

It can be viewed at:

http://localhost/status.html

## Cron Automation

Cron runs the monitoring cycle every 15 minutes.

Schedule:

*/15 * * * *

The final cron configuration is preserved at:

evidence/final-crontab.txt

## Generated Files

The following files change whenever monitoring runs:

- reports/health-report.txt
- reports/cron-health-check.log
- reports/monitoring-cycle.log
- web/status.html

These files are ignored by Git.

A stable dashboard sample is stored at:

evidence/status-dashboard-sample.html

## Why This Matters For DevOps

This workflow demonstrates:

- Linux service monitoring
- Bash automation
- Conditional health checks
- Cron scheduling
- HTML generation
- Nginx publishing
- Generated-file management with Git
- Operational reporting
