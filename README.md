# Fail2Ban-Report-Docker


dockerfile : installiert umgebung und kopiert alles aus Fail2Ban-Report/ in den Webhost des Containers nach /var/www/html/

im Container haben wir dann also /var/www/html/Fail2Ban-Report/


```
/
├── Shellscripts/          # Bash-Skripte (fail2ban_log2json.sh, firewall-update.sh)
├── Fail2Ban-Report/       # Web-Frontend + PHP + assets + archive (für Docker COPY)
├── installer.sh           # Installationsskript
├── docker-compose.yml     # Docker Compose Konfiguration
└── Dockerfile             # Dockerfile für das Web-Frontend

```
