# Service Management

This section documents how I managed the Nginx service using systemctl.

## Commands Practised

systemctl is-active nginx
sudo systemctl stop nginx
sudo systemctl start nginx
sudo systemctl restart nginx
curl -I localhost

## What Is A Service?

A service is a background process managed by the operating system.

Nginx runs as a service so it can continue serving web requests without needing a user to manually run it in the terminal.

## Checking If Nginx Is Active

Command used:

systemctl is-active nginx

When Nginx was running, the output was:

active

## Stopping Nginx

Command used:

sudo systemctl stop nginx

After stopping Nginx, the service became inactive and localhost stopped responding.

This showed that the web page depends on the Nginx service running.

## Starting Nginx

Command used:

sudo systemctl start nginx

After starting Nginx again, the service returned to:

active

Then this command confirmed the web server was responding again:

curl -I localhost

The response included:

HTTP/1.1 200 OK

## Why curl -I Is Useful

curl -I shows only the HTTP response headers.

It is useful for quickly checking whether a web server is responding without downloading the full page body.

## Why This Matters For DevOps

DevOps engineers need to manage services running on Linux servers.

Knowing how to stop, start, restart, inspect, and test services is important for deployments, troubleshooting, monitoring, and incident response.
