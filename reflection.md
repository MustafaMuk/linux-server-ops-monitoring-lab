# Project Reflection

## Overview

This project moved beyond basic Linux command practice and introduced me to practical Linux server operations.

I installed and managed an Nginx web server, inspected service logs, wrote Bash monitoring scripts, automated recurring health checks with cron, simulated an outage, recovered the service, and published a browser-based monitoring dashboard.

## What I Built

I created:

- A local Nginx web server
- A custom HTML webpage
- A Bash system-health script
- An HTTP availability check
- Failure and recovery evidence
- A cron-based monitoring schedule
- An HTML health dashboard
- A complete monitoring-cycle script
- Technical documentation for each stage

## Most Important Concepts

### Linux Services

I learned that services are background processes managed by systemd.

I used `systemctl` to:

- Check Nginx status
- Stop Nginx
- Start Nginx
- Restart Nginx
- Confirm whether Nginx was active

### Log Investigation

I used `journalctl` and Nginx log files to inspect:

- Service start and stop events
- Successful HTTP requests
- Access-log entries
- Error-log information

This showed me why logs are one of the first places engineers should inspect when troubleshooting.

### Bash Automation

I created Bash scripts that:

- Collected system information
- Checked Nginx service status
- Tested HTTP availability
- Generated health reports
- Generated an HTML dashboard
- Published the dashboard through Nginx

### Cron Scheduling

I configured cron to run the complete monitoring cycle every 15 minutes.

This demonstrated how Linux can perform recurring operational work without manual intervention.

### Failure Detection and Recovery

I deliberately stopped Nginx and confirmed that the monitoring script detected:

- An inactive service
- An unhealthy HTTP check
- HTTP code 000

After restarting Nginx, I verified:

- The service returned to active
- The HTTP check returned healthy
- The server returned HTTP code 200

## Challenges

One challenge was handling files that changed whenever the monitoring scripts ran.

I solved this by using `.gitignore` to exclude generated reports, logs, and dashboard files while preserving stable evidence copies inside the repository.

This helped me understand the difference between source files, generated files, and evidence.

## What I Learned

The main lesson from this project is that server administration is not only about installing software.

It also involves:

- Checking service health
- Reading logs
- Testing availability
- Automating repeated tasks
- Detecting failures
- Recovering services
- Verifying recovery
- Documenting the complete process

## DevOps Relevance

This project introduced practical concepts that connect directly to DevOps work:

- Linux operations
- Web-server management
- Bash automation
- Monitoring
- Scheduled tasks
- Incident simulation
- Service recovery
- Git-based documentation

The project provides a foundation for future work involving networking, Docker, cloud infrastructure, Terraform, CI/CD, and more advanced monitoring tools.
