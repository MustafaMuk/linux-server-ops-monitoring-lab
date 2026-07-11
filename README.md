# Linux Server Operations & Monitoring Lab

## Overview

This project demonstrates practical Linux server administration, monitoring, automation, and troubleshooting using Nginx and Bash.

I built and managed a local Nginx web server, created automated system-health checks, investigated service logs, simulated an outage, recovered the service, and generated a browser-based monitoring dashboard.

## Features

- Nginx web-server installation and management
- Custom HTML webpage
- Linux service management with `systemctl`
- Log investigation using `journalctl` and Nginx logs
- Bash system-health checks
- Nginx service and HTTP availability monitoring
- Controlled failure and recovery testing
- Cron scheduling every 15 minutes
- Automatic HTML dashboard generation
- Dashboard publishing through Nginx
- Git-managed documentation and evidence

## Monitoring Dashboard

The local dashboard is served at:

`http://localhost/status.html`

It displays:

- Overall server health
- Hostname
- Current user
- System uptime
- Disk usage
- Memory usage
- Nginx service status
- HTTP response code
- Last update time

## Project Structure

    linux-server-ops-monitoring-lab/
    ├── README.md
    ├── docs/
    │   ├── architecture.md
    │   ├── cron-automation.md
    │   ├── dashboard-automation.md
    │   ├── health-check-script.md
    │   ├── log-investigation.md
    │   ├── nginx-setup.md
    │   ├── service-management.md
    │   └── troubleshooting.md
    ├── evidence/
    │   ├── command-outputs.md
    │   ├── cron-execution.txt
    │   ├── cron-health-check-sample.txt
    │   ├── final-crontab.txt
    │   ├── nginx-failure-report.txt
    │   ├── nginx-recovery-report.txt
    │   └── status-dashboard-sample.html
    ├── reports/
    ├── scripts/
    │   ├── generate-dashboard.sh
    │   ├── health-check.sh
    │   └── run-monitoring-cycle.sh
    ├── web/
    │   └── index.html
    └── reflection.md

## Main Scripts

### Health Check

Run:

`./scripts/health-check.sh`

This script checks Linux system health, Nginx service status, and HTTP availability.

### Dashboard Generator

Run:

`./scripts/generate-dashboard.sh`

This script collects live system information and generates the HTML monitoring dashboard.

### Complete Monitoring Cycle

Run:

`./scripts/run-monitoring-cycle.sh`

This script:

1. Runs the system health check
2. Generates the dashboard
3. Publishes the dashboard through Nginx
4. Records monitoring output

## Service Management

Commands practised:

- `systemctl status nginx`
- `sudo systemctl stop nginx`
- `sudo systemctl start nginx`
- `sudo systemctl restart nginx`
- `systemctl is-active nginx`

## Log Investigation

Commands practised:

- `sudo journalctl -u nginx --no-pager`
- `sudo tail -20 /var/log/nginx/access.log`
- `sudo tail -20 /var/log/nginx/error.log`

## Monitoring Schedule

Cron runs the complete monitoring cycle every 15 minutes:

`*/15 * * * *`

## Failure and Recovery Test

I deliberately stopped Nginx and confirmed that the monitoring script detected:

- `INACTIVE`
- `UNHEALTHY`
- HTTP code `000`

After restarting Nginx, the script confirmed recovery:

- `ACTIVE`
- `HEALTHY`
- HTTP code `200`

## Skills Demonstrated

- Linux system administration
- Nginx administration
- Bash scripting
- Service management
- System monitoring
- HTTP health checks
- Log analysis
- Cron automation
- Incident simulation and recovery
- Git version control
- Technical documentation

## Tools Used

- Ubuntu on WSL2
- Nginx
- Bash
- systemd
- systemctl
- journalctl
- cron
- curl
- Git
- HTML and CSS
