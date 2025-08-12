# Fail2Ban-Report-Docker

> A simple and clean web-based dashboard to turn your daily Fail2Ban logs into searchable and filterable JSON reports — with optional IP blocklist management for UFW.

**Integration**
>Designed for easy integration on a wide range of Linux systems — from small Raspberry Pis to modest business setups — though it’s not (yet) targeted at large-scale enterprise environments.
Flexibility comes from the two backend shell scripts, which you can adapt to your specific environment or log sources to provide the JSON data the web interface needs (daily JSON event files).

🛡️ **Note**: This tool is a visualization and management layer — it does **not** replace proper intrusion detection or access control. Deploy it behind IP restrictions or HTTP authentication.

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


## 🆕 What's New in V 0.3.3 (QoL Update)
### ⚠️ Warning System and Pending Status Indicators
- 🚨 New [Warnings] section in .config to configure warning & critical thresholds (events per minute per jail) in format warning:critical (e.g: 20:50).
- 👀 warning & critical status indicators (colored dots) in the header for quick overview.
- ⏳ Manual block/unblock actions now mark IPs as pending until processed by firewall-update.
- 📊 Pending entries are now visible in blocklist stats for better tracking.

### ✔️ Multi-Selection UI and Bulk Actions for Ban & Report
- ✅ Switched from per-row action buttons to checkbox multi-selection for IPs.
- 📋 New dedicated “Ban” and “Info” buttons for bulk processing.
- 🔄 Frontend updated to handle and display results for multiple IP actions simultaneously.
- 🔔 New notification system for success/info/error messages on each action.

### 🛠 Backend Improvements & New IP Reporting
- 🔄 Backend now accept arrays of IPs for ban and report actions, with detailed aggregated feedback.
- 🆕 Added IPInfo API integration alongside AbuseIPDB for richer geolocation and network info.
- ⏲️ Built-in delay between report requests to avoid API rate limits.
- ⚙️ Improved error handling and user feedback for multi-IP operations.

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

## 🤝 Contributing

- Found a bug? → [Open an issue](https://github.com/SubleXBle/Fail2Ban-Report/issues)

---




# Fail2Ban-Report – Docker Installation Guide

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
