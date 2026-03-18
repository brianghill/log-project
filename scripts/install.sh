#!/bin/bash

#############################################
# AnchorPoint Monitoring - Installer v2
#############################################

echo "🚀 Starting AnchorPoint Monitoring installation..."

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG_DIR="$BASE_DIR/config"
CONFIG_FILE="$CONFIG_DIR/config.conf"
TEMPLATE_FILE="$CONFIG_DIR/config.template.conf"

REPORT_DIR="$HOME/monitoring-reports"
CENTRAL_DIR="$HOME/central-monitoring"
LOG_DIR="$BASE_DIR/logs"

#############################################
# Step 1 - Directories
#############################################

echo "📁 Creating directories..."

mkdir -p "$REPORT_DIR"
mkdir -p "$CENTRAL_DIR"
mkdir -p "$LOG_DIR"

echo "✅ Directories ready."

#############################################
# Step 2 - Config Setup
#############################################

echo "⚙️ Setting up configuration..."

if [ ! -f "$CONFIG_FILE" ]; then
    if [ -f "$TEMPLATE_FILE" ]; then
        cp "$TEMPLATE_FILE" "$CONFIG_FILE"
        echo "✅ Config created from template."
    else
        echo "❌ Template config not found!"
        exit 1
    fi
else
    echo "ℹ️ Config already exists. Skipping."
fi

#############################################
# Step 3 - Required Commands
#############################################

echo "🔍 Checking required commands..."

REQUIRED_CMDS=("df" "free" "uptime" "grep" "awk" "scp" "ssh")

for cmd in "${REQUIRED_CMDS[@]}"; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "❌ Missing command: $cmd"
        exit 1
    fi
done

echo "✅ All required commands available."

#############################################
# Step 4 - Permissions
#############################################

echo "🔐 Setting script permissions..."

chmod +x "$BASE_DIR/scripts/"*.sh 2>/dev/null

echo "✅ Permissions set."

#############################################
# Step 5 - Cron Setup (auto monitoring)
#############################################

echo "⏱ Setting up automated monitoring..."

CRON_JOB="*/5 * * * * $BASE_DIR/scripts/run-monitoring.sh"

(crontab -l 2>/dev/null | grep -v "run-monitoring.sh"; echo "$CRON_JOB") | crontab -

echo "✅ Monitoring scheduled every 5 minutes."

#############################################
# Step 6 - Email Capability Check
#############################################

echo "📧 Checking mail capability..."

if command -v mail &> /dev/null; then
    echo "✅ Mail command found."
else
    echo "⚠️ Mail not installed. Run: sudo apt install mailutils msmtp msmtp-mta"
fi

#############################################
# Step 7 - Final Output
#############################################

echo ""
echo "🎉 INSTALLATION COMPLETE"
echo "--------------------------------------"
echo "Reports: $REPORT_DIR"
echo "Central: $CENTRAL_DIR"
echo "Config:  $CONFIG_FILE"
echo ""
echo "👉 Next Steps:"
echo "1. Edit config: nano $CONFIG_FILE"
echo "2. Test run: $BASE_DIR/scripts/run-monitoring.sh"
echo "3. View dashboard:"
echo "   watch -n 5 $BASE_DIR/scripts/central-dashboard.sh"
echo ""
echo "🔥 AnchorPoint Monitoring is LIVE."
