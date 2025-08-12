#!/bin/bash

set -euo pipefail

# --- Funktionen ---

info()    { echo -e "\033[1;34m[INFO]\033[0m $*"; }
warn()    { echo -e "\033[1;33m[WARN]\033[0m $*"; }
error()   { echo -e "\033[1;31m[ERROR]\033[0m $*"; }
confirm() {
  # Ja/Nein Abfrage (default nein)
  while true; do
    read -rp "$1 [y/N]: " yn
    case "$yn" in
      [Yy]*) return 0 ;;
      [Nn]*|"") return 1 ;;
      *) echo "Please answer y or n." ;;
    esac
  done
}

# --- Variablen ---
INSTALL_ROOT="/opt/Fail2Ban-Report"
WEBROOT="/var/www/html/Fail2Ban-Report"
ARCHIVE_DIR="$WEBROOT/archive"
CONFIG_FILE="$INSTALL_ROOT/fail2ban-report.config"
LOGFILE="/var/log/Fail2Ban-Report.log"

# --- 1. System prüfen ---
REQUIRED_PKGS=(fail2ban ufw jq cron bash)

info "Checking required packages..."
MISSING_PKGS=()
for pkg in "${REQUIRED_PKGS[@]}"; do
  if ! command -v "$pkg" &>/dev/null; then
    MISSING_PKGS+=("$pkg")
  fi
done

if [ ${#MISSING_PKGS[@]} -gt 0 ]; then
  warn "Missing packages: ${MISSING_PKGS[*]}"
  if confirm "Install missing packages? (requires sudo)"; then
    if command -v apt &>/dev/null; then
      sudo apt update
      sudo apt install -y "${MISSING_PKGS[@]}"
    elif command -v yum &>/dev/null; then
      sudo yum install -y "${MISSING_PKGS[@]}"
    else
      error "Unsupported package manager. Please install manually: ${MISSING_PKGS[*]}"
      exit 1
    fi
  else
    error "Cannot continue without required packages."
    exit 1
  fi
else
  info "All required packages are installed."
fi

# --- 2. Ordner anlegen + Rechte setzen ---
info "Preparing folders..."

sudo mkdir -p "$INSTALL_ROOT"
sudo mkdir -p "$ARCHIVE_DIR"

sudo chown -R www-data:www-data "$ARCHIVE_DIR"
sudo chmod -R 755 "$ARCHIVE_DIR"

# --- 3. Shellscripts vorbereiten ---
info "Copying and configuring shell scripts..."

# Beispiel: Annahme die Scripts liegen im Ordner ./scripts
SCRIPTS_SRC="./scripts"
SCRIPTS_DST="$INSTALL_ROOT"

if [ ! -d "$SCRIPTS_SRC" ]; then
  error "Scripts source directory '$SCRIPTS_SRC' does not exist!"
  exit 1
fi

sudo cp "$SCRIPTS_SRC/fail2ban_log2json.sh" "$SCRIPTS_DST/"
sudo cp "$SCRIPTS_SRC/firewall-update.sh" "$SCRIPTS_DST/"

# Pfade in den Scripts anpassen (archive Ordner)
sudo sed -i "s|BLOCKLIST_DIR=.*|BLOCKLIST_DIR=\"$ARCHIVE_DIR\"|" "$SCRIPTS_DST/firewall-update.sh"
sudo sed -i "s|OUTPUT_JSON_DIR=.*|OUTPUT_JSON_DIR=\"$ARCHIVE_DIR\"|" "$SCRIPTS_DST/fail2ban_log2json.sh"

sudo chmod +x "$SCRIPTS_DST/fail2ban_log2json.sh" "$SCRIPTS_DST/firewall-update.sh"

# --- 4. Config erstellen / anpassen ---
info "Creating configuration..."

# Funktion zur Eingabe mit Default-Wert
prompt_default() {
  local prompt="$1"
  local default="$2"
  read -rp "$prompt [$default]: " input
  echo "${input:-$default}"
}

REPORT_ENABLED=$(prompt_default "Enable reports? (true/false)" "false")
while [[ ! "$REPORT_ENABLED" =~ ^(true|false)$ ]]; do
  warn "Please enter 'true' or 'false'."
  REPORT_ENABLED=$(prompt_default "Enable reports? (true/false)" "false")
done

if [ "$REPORT_ENABLED" == "true" ]; then
  read -rp "Enter AbuseIPDB API Key (leave empty to skip): " ABUSEIPDB_KEY
  read -rp "Enter IPInfo API Key (leave empty to skip): " IPINFO_KEY
else
  ABUSEIPDB_KEY=""
  IPINFO_KEY=""
fi

MAX_DISPLAY_DAYS=$(prompt_default "Number of days to display in Fail2Ban report" "7")
while ! [[ "$MAX_DISPLAY_DAYS" =~ ^[0-9]+$ ]]; do
  warn "Please enter a valid number."
  MAX_DISPLAY_DAYS=$(prompt_default "Number of days to display in Fail2Ban report" "7")
done

WARNINGS_ENABLED=$(prompt_default "Enable warnings? (true/false)" "true")
while [[ ! "$WARNINGS_ENABLED" =~ ^(true|false)$ ]]; do
  warn "Please enter 'true' or 'false'."
  WARNINGS_ENABLED=$(prompt_default "Enable warnings? (true/false)" "true")
done

if [ "$WARNINGS_ENABLED" == "true" ]; then
  read -rp "Warning threshold (blocks/jail/min) (e.g. 10): " WARN_THRESHOLD
  read -rp "Critical threshold (blocks/jail/min) (e.g. 50): " CRIT_THRESHOLD

  # Validierung
  until [[ "$WARN_THRESHOLD" =~ ^[0-9]+$ ]] && [[ "$CRIT_THRESHOLD" =~ ^[0-9]+$ ]] && [ "$WARN_THRESHOLD" -lt "$CRIT_THRESHOLD" ]; do
    warn "Thresholds must be positive integers and Warning < Critical."
    read -rp "Warning threshold (blocks/jail/min): " WARN_THRESHOLD
    read -rp "Critical threshold (blocks/jail/min): " CRIT_THRESHOLD
  done

  THRESHOLD="${WARN_THRESHOLD}:${CRIT_THRESHOLD}"
else
  THRESHOLD="0:0"
fi

# Config schreiben
sudo bash -c "cat > '$CONFIG_FILE' <<EOF
[reports]
report=$REPORT_ENABLED
report_types=abuseipdb,ipinfo

[AbuseIPDB API Key]
abuseipdb_key=$ABUSEIPDB_KEY

[IPInfo API Key]
ipinfo_key=$IPINFO_KEY

[Fail2Ban-Daily-List-Settings]
max_display_days=$MAX_DISPLAY_DAYS

[Warnings]
enabled=$WARNINGS_ENABLED
threshold=$THRESHOLD
EOF"

sudo chown root:www-data "$CONFIG_FILE"
sudo chmod 644 "$CONFIG_FILE"

info "Configuration saved to $CONFIG_FILE"

# --- 5. Cronjob einrichten ---
if confirm "Do you want to set up cronjobs to run the shell scripts periodically?"; then
  echo "Choose interval in minutes (recommended 5, 10, or 15):"
  read -rp "Interval [5]: " CRON_INTERVAL
  CRON_INTERVAL=${CRON_INTERVAL:-5}
  if [[ ! "$CRON_INTERVAL" =~ ^(5|10|15)$ ]]; then
    warn "Invalid interval, defaulting to 5 minutes."
    CRON_INTERVAL=5
  fi

  # Cronjob für fail2ban_log2json.sh
  (sudo crontab -l 2>/dev/null | grep -v 'fail2ban_log2json.sh'; echo "*/$CRON_INTERVAL * * * * $INSTALL_ROOT/fail2ban_log2json.sh >> $LOGFILE 2>&1") | sudo crontab -

  # Cronjob für firewall-update.sh
  (sudo crontab -l 2>/dev/null | grep -v 'firewall-update.sh'; echo "*/$CRON_INTERVAL * * * * $INSTALL_ROOT/firewall-update.sh >> $LOGFILE 2>&1") | sudo crontab -

  info "Cronjobs set to run every $CRON_INTERVAL minutes."
else
  info "Skipping cronjob setup."
fi

# --- 6. Docker prüfen und Container starten ---
if command -v docker &>/dev/null && command -v docker-compose &>/dev/null; then
  info "Docker and docker-compose found."

  if confirm "Build and start Docker container now?"; then
    docker-compose build
    docker-compose up -d
    info "Docker container started."
  else
    info "You can build and start the Docker container manually later."
  fi
else
  warn "Docker or docker-compose not found. Please install manually or run the web interface without Docker."
fi

info "Installation complete!"
