# Fail2Ban-Report-Docker
> Beta 4 : Version 0.4.0 : Docker

you asked for 🐳, so i built a 🐳 : ⭐ if you like it

> A simple and clean web-based dashboard to turn your daily Fail2Ban logs into searchable and filterable JSON reports — with optional IP blocklist management for UFW.

> This version brings more stability and performance, as well as improved visibility into Fail2Ban events.

**Integration**
>Designed for easy integration on a wide range of Linux systems — from small Raspberry Pis to modest business setups — though it’s not (yet) targeted at large-scale enterprise environments.
Flexibility comes from the two backend shell scripts, which you can adapt to your specific environment or log sources to provide the JSON data the web interface needs (daily JSON event files).

🛡️ **Note**: This tool is a visualization and management layer — it does **not** replace proper intrusion detection or access control. Deploy it behind IP restrictions or HTTP authentication.

## 🐳 Docker Specifics
> The Docker version is always based on the native version and therefore receives updates after the native release, with a slight delay to ensure stability and integration.

> The Docker-Version of Fail2Ban-Report has all you need for an easy start - single Script Setup - you can access archive/ to manage blocklists and /opt/Fail2Ban-Report/ for Settings like in the native Version, all Web-Related Stuff is inside of the container. There is a Helper-Script.sh to enable you to take actions in the container itself to propper set up .htaccess, therefore nano is present in the container.


## Installation
Please read the [Installation-Guide](#Installation-Guide) carefully!

---

## 📚 What It Does
Fail2Ban-Report parses your `fail2ban.log` and generates JSON-based reports viewable via a responsive web dashboard.  
It provides optional tools to:  

- 📊 Visualize **ban** and **unban** events, including per-jail statistics  
- ⚡ Interact with IPs (e.g., manually block, unblock, or report to external services)  
- 📂 Maintain **jail-specific** persistent blocklists (JSON) with `active` and `pending` status  
- 🔄 Sync those lists with your system firewall using **ufw**  
- 🚨 Show **warning indicators** when ban rates exceed configurable thresholds  

> **Note:** Direct integration with other firewalls or native Fail2Ban jail commands is not yet implemented.

---

## 🧱 Architecture Overview
- **Backend Shell Scripts**:  
  - Parse logs and generate daily JSON event files  
  - Maintain and update `*.blocklist.json`  
  - Apply or remove firewall rules based on blocklist entries (`ufw`)  

- **Frontend Web Interface**:  
  - Displays event timelines, statistics, and per-jail blocklists  
  - Allows **multi-selection** for bulk ban/report actions  
  - Shows **pending status** for unprocessed manual actions  
  - Displays real-time warning indicators  

- **JSON Blocklists**:  
  - Stored per jail  
  - Contain IP entries with metadata (`active`, `pending`, timestamps, jail name)  

---

## 📦 Features

- 🔍 **Searchable + filterable** log reports (date, jail, IP)
- 🔧 **Integrated JSON blocklist** for persistent Block-Overview
- 🧱 **Firewall sync** using UFW (planned: nftables, firewalld)
- ⚡ **Lightweight setup** — no DB, no frameworks
- 🔐 **Compatible with hardened environments** (no external assets, strict headers)
- 🛠️ **Installer script** to automate setup and permissions
- 🧩 **Modular design** for easy extension
- 🪵 Optional logging of block/unblock actions (set true/false and logpath in `firewall-update.sh`)
- 🕵️ **Optional Feature :** IP reputation check via AbuseIPDB (manual lookup from web interface)

> 🧰 Works even on small setups (Raspberry Pi, etc.)

---

## 👥 Discussions

> If you want to join the conversation or have questions or ideas, visit the 💬 [Discussions page](https://github.com/SubleXBle/Fail2Ban-Report/discussions).


## 🆕 What's New in V 0.4.0

### 🧱 Firewall & JSON
- Optimized `firewall-update.sh` for faster batch processing of IPs.
- Batch blocking per jail with a single `ufw reload`.
- Safe unblocking with rule renumbering and reload after each deletion.
- JSON updates and cleanup done once per jail, not per IP.
- Core mechanisms, logging, and permissions unchanged.
> This significantly reduces both the runtime and the lock duration of the blocklists, especially during ban events.

### 🖥️ UI & Statistics
- Minor visual improvements in:
  - `header.php`, `fail2ban-logstats.php`, `fail2ban-logstats.js`
  - `index.php` (IP sorting)
  - `style.css`

### 🟡🔴 Marker Feature
- **IP Event Markers**: Highlights repeated events (yellow) and IPs in multiple jails (red).
- **Sortable & Filterable Mark Column**: New column `Mark` with dropdown filter.
- **Dynamic Filtering**: Markers update live with Action, Jail, IP, or Date filters.
- Marker column placed between Action and IP, responsive layout preserved.

### ✨ New Feature: Copy Filtered Data to Clipboard

- **Added** a new "Copy to Clipboard" button to export the currently **filtered table data**.
- **Implemented** a dedicated JavaScript file `assets/js/table-export.js` for the copy functionality.
- **Integration** with existing DataTables filtering logic to ensure only visible/filtered rows are copied.
- **Output Format**: Tab-separated values (TSV) with all HTML tags removed for clean text export.
- **User Feedback**: 
  - Shows a warning if there’s no data to copy.
  - Shows a success or error alert based on the clipboard operation result.
---

## ✅ What It Is
- A **read-only + action-enabled** web dashboard for Fail2Ban events  
- A tool to **visualize** bans/unbans and **manually** manage blocked IPs  
- A **log parser + JSON generator** that works alongside your existing Fail2Ban setup  
- A way to **sync a persistent blocklist** with your firewall (currently **UFW only**)  
- Designed for **sysadmins** who want quick insights without SSH-ing into the server  

## ❌ What It Is Not
- ❌ A replacement for **Fail2Ban** itself (it depends on Fail2Ban)  
- ❌ A real-time IDS/IPS (data updates depend on log parsing intervals)  
- ❌ A universal firewall manager (no native support for iptables/nftables, etc. — yet)  
- ❌ A tool for **automatic** jail management (manual actions only for now)  
- ❌ A heavy analytics platform — it’s lightweight and log-driven by design  

---

## 🪳 Bugfixes

> - Found a bug? → [Open an issue](https://github.com/SubleXBle/Fail2Ban-Report/issues)

- ✅ 

---

## 🤝 Contributing

- Found a bug? → [Open an issue](https://github.com/SubleXBle/Fail2Ban-Report/issues)

---




# Installation-Guide

## Requirements
> Before you begin, make sure the following are installed on your host system:

+ Docker (latest stable version)
+ Docker Compose (v2 or later)
+ a working Fail2Ban setup with log files accessable for shellscripts
+ UFW installed


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

> if you are familiar with docker, you can easy change the dockerfile and docker-compose.yml or .htaccess to fit your needs (e.g.: ports) prior installation.


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

> The Installer will show you defaults : you **HAVE** to type in something (e.g.: defaults that are shown by Installer) else it will not be set in config!

### 4 Execute Helper-Script

```
./Helper-Script
```
this will take you to /var/www/html of the Container, so you can:
- edit .htaccess for more security
- create a .htpasswd (best place would be in /var/www/ - so outside of the webroot)
- you can also create a html file in www with a redirect to Fail2Ban-Report/ or whatever you like


### 4 Access the web interface
After installation, open your browser and visit:
```
https://<your-server-ip>/Fail2Ban-Report
```
> (Default port is defined in docker-compose.yml.)

## First Login & Security


First Login ... 


## Maintenance

> restart container
```
docker-compose stop && docker-compose start
```
or
```
docker-compose restart
```
If you want to Reset the installation you can do so by stopping the container

```
docker-compose stop
```
then you can delete the container
```
docker container prune
```
and rebuild it
```
docker-compose build && docker-compose up -d
```
then everything in Web will be reinstalled, Stuff outside of Web will persist
