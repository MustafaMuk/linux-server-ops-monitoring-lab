# Architecture

This project uses a simple local Linux web server setup.

## Basic Flow

Browser or curl
↓
localhost
↓
Nginx web server
↓
/var/www/html/index.html
↓
Custom HTML page

## Components

### WSL2 Ubuntu

The Linux environment used for this project.

### Nginx

The web server used to serve the custom HTML page.

### Project Web File

The project copy of the webpage is stored at:

web/index.html

### Nginx Web Root

The live webpage served by Nginx is stored at:

/var/www/html/index.html

## Request Flow

When I run:

curl localhost

or visit:

http://localhost

the request goes to Nginx. Nginx then returns the HTML file from /var/www/html/index.html.

## Why This Matters

This shows how a Linux web server serves content from a specific directory.

Understanding this is useful for DevOps because web applications, static sites, reverse proxies, containers, and cloud deployments all rely on similar request and service concepts.
