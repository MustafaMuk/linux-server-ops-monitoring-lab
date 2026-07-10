# Nginx Failure Detection and Recovery

## Scenario

I deliberately stopped the Nginx service to test whether the Bash health-check script could detect a web-server outage.

## Failure Simulation

I stopped Nginx using:

sudo systemctl stop nginx

I confirmed the service state using:

systemctl is-active nginx

The output was:

inactive

## Health-Check Result During Failure

I ran:

./scripts/health-check.sh

The script reported:

Nginx service status:
INACTIVE

Nginx HTTP check:
UNHEALTHY - localhost returned HTTP 000

HTTP code 000 means curl could not establish a successful HTTP connection because Nginx was not listening for requests.

The failed report was preserved at:

evidence/nginx-failure-report.txt

## Recovery

I restarted Nginx using:

sudo systemctl start nginx

I then confirmed that the service was active:

systemctl is-active nginx

After rerunning the health-check script, it reported:

Nginx service status:
ACTIVE

Nginx HTTP check:
HEALTHY - localhost returned HTTP 200

The recovered report was preserved at:

evidence/nginx-recovery-report.txt

## What This Demonstrates

This test demonstrates:

- Controlled service failure
- Service-state inspection
- Automated failure detection
- HTTP availability checking
- Service recovery
- Verification after recovery
- Preservation of incident evidence

## Why This Matters For DevOps

Monitoring is useful only when it can distinguish between healthy and failed systems.

Testing both failure and recovery proves that the health-check logic works under more than ideal conditions.
