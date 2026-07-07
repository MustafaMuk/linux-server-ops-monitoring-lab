
# Nginx Service Management

## Commands Used

systemctl is-active nginx
sudo systemctl stop nginx
sudo systemctl start nginx
curl -I localhost

## Result

Nginx was stopped and localhost stopped responding.

Nginx was then started again and returned to an active state.

curl -I localhost returned:

HTTP/1.1 200 OK

This confirmed that the Nginx service recovered successfully.
