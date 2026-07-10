# Cron Health-Check Automation

## Purpose

Cron was used to run the Linux server health-check script automatically.

The script checks system health, Nginx service status, and HTTP availability without requiring manual execution.

## Script

The scheduled script is:

scripts/health-check.sh

## Initial Test Schedule

The script was initially scheduled to run every minute:

* * * * *

This temporary schedule allowed me to confirm quickly that cron was executing the script correctly.

## Final Schedule

After testing, the schedule was changed to:

*/15 * * * *

This runs the health check every 15 minutes.

## Cron Command

The scheduled command runs the health-check script and appends its terminal output to:

reports/cron-health-check.log

The script also updates:

reports/health-report.txt

## Verification

Cron execution was verified using:

journalctl -u cron --since "15 minutes ago" --no-pager

The journal showed cron running the health-check script automatically under the colonel user.

Evidence is stored in:

evidence/cron-execution.txt
evidence/cron-health-check-sample.txt

## Generated Files

The live health report and cron log change whenever the scheduled task runs.

They are excluded from Git using .gitignore.

Stable evidence copies are stored inside the evidence directory.

## Why This Matters For DevOps

Scheduled tasks are useful for:

- Health checks
- Backups
- Log collection
- Maintenance
- Report generation
- Automated monitoring

Cron demonstrates how Linux can perform recurring operational work without manual intervention.
