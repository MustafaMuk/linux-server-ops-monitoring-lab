# Project Architecture

## Overview

This project runs and monitors a local Nginx web server inside Ubuntu on WSL2.

A Bash-based monitoring workflow collects system information, checks Nginx availability, generates reports, builds an HTML dashboard, and publishes that dashboard through Nginx.

## Monitoring Workflow

```text
Cron Scheduler
      |
      v
run-monitoring-cycle.sh
      |
      +-----------------------------+
      |                             |
      v                             v
health-check.sh            generate-dashboard.sh
      |                             |
      v                             v
health-report.txt              status.html
                                      |
                                      v
                          /var/www/html/status.html
                                      |
                                      v
                           Nginx Web Server
                                      |
                                      v
                       http://localhost/status.html
```

## Main Components

### Nginx

Nginx serves the project pages over HTTP.

The monitoring dashboard is available at:

```text
http://localhost/status.html
```

### Health-Check Script

The script:

```text
scripts/health-check.sh
```

checks:

- Hostname
- Current user
- Uptime
- Disk usage
- Memory usage
- Nginx service status
- HTTP response code

### Dashboard Generator

The script:

```text
scripts/generate-dashboard.sh
```

collects live system information and creates an HTML dashboard.

### Monitoring-Cycle Script

The script:

```text
scripts/run-monitoring-cycle.sh
```

controls the complete workflow:

1. Runs the health check
2. Generates the dashboard
3. Publishes the dashboard through Nginx
4. Records monitoring output

### Cron

Cron runs the monitoring cycle every 15 minutes:

```text
*/15 * * * *
```

## Failure Detection

If Nginx is stopped:

- The service check reports `INACTIVE`
- The HTTP check reports `UNHEALTHY`
- Curl returns HTTP code `000`

After Nginx is restarted:

- The service check reports `ACTIVE`
- The HTTP check reports `HEALTHY`
- Curl returns HTTP code `200`

## Technologies Used

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
