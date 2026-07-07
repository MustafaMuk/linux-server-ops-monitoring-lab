# Nginx Setup

## What Is Nginx?

Nginx is a web server.

A web server listens for HTTP requests and returns web content such as HTML pages, images, or application responses.

In this project, Nginx is used to serve a local web page from my Linux environment.

## Installation

Nginx was installed using Ubuntu's package manager.

Commands used:

sudo apt update
sudo apt install -y nginx

## Checking The Service

After installation, I checked the Nginx service with:

systemctl status nginx

The service showed:

active (running)

This means Nginx was successfully running as a Linux service.

## Testing With Curl

The local web server was tested with:

curl localhost

This returned the default Nginx welcome page.

## Key Concepts

### Web Server

A web server receives HTTP requests and returns web content.

### Localhost

localhost refers to the current machine.

Testing localhost means I am asking my own machine to respond.

### Service

A service is a background process managed by the operating system.

Nginx runs as a service so it can keep serving web requests in the background.

### systemctl

systemctl is used to manage services on Linux systems that use systemd.

Common examples:

systemctl status nginx
systemctl start nginx
systemctl stop nginx
systemctl restart nginx

## Why This Matters For DevOps

DevOps engineers often work with services running on Linux servers.

Understanding how to install, start, stop, inspect, and test a service is a core operations skill.
