version: "3.9"

services:
  fail2ban-report:
    build: .
    container_name: fail2ban-report
    ports:
      - "8080:80"   # Container-Port 80 -> Host-Port 8080
    volumes:
      # Mount the webroot from host to container
      - /var/www/Fail2Ban-Report:/var/www/Fail2Ban-Report:rw
    restart: unless-stopped
