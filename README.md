# Fail2Ban-Report-Docker


# Fail2Ban-Report – Docker Installation Guide

## Requirements
> Before you begin, make sure the following are installed on your host system:

+ Docker (latest stable version)
+ Docker Compose (v2 or later)
+ a working Fail2Ban setup with log files accessable for shellscripts


## Directory Structure
> Your project should look like this:

```
/
├── Shellscripts/          # Bash scripts used inside/outside Docker
├── Fail2Ban-Report/       # Web frontend + PHP + assets + archive (copied into container)
├── installer.sh           # Automatic installation script for Docker
├── docker-compose.yml     # Docker Compose configuration
└── Dockerfile             # Dockerfile for the web frontend

```

## Installation Steps

### 1 Download the repository

ether per .zip File or

```
git clone https://github.com/<your-repo>/Fail2Ban-Report.git
cd Fail2Ban-Report
```
### 2 Make Installer executeable
```
chmod +x installer.sh
```

### 3 Run the Installer
```
./installer.sh
```

#### The script will:

+ Build the Docker image
+ Set up and start the Docker container
+ Configure volume mounts for data persistence
+ Apply initial permissions for the archive directory

### 4 Access the web interface
After installation, open your browser and visit:
```
https://<your-server-ip>:<port>
```
> (Default port is defined in docker-compose.yml.)

## First Login & Security

The web interface is protected with .htpasswd authentication.

If you don’t have an .htpasswd file yet, you can use the built-in generator at:

## Maintenance

> restart container
```
docker compose restart
```

```
```

```
```

```
```
