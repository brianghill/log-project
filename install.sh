#!/bin/bash
set -e

BASE_DIR="$HOME/log-project"
TEMPLATE_DIR="$BASE_DIR/templates"
SCRIPT_DIR="$BASE_DIR/scripts"
LOG_DIR="$BASE_DIR/logs"

echo "Starting AnchorPoint Monitoring installation..."

# -----------------------------
# 1️⃣ Ensure directory structure
# -----------------------------
mkdir -p "$SCRIPT_DIR"
mkdir -p "$LOG_DIR"
mkdir -p "$BASE_DIR/reports/clients"
mkdir -p "$TEMPLATE_DIR"

echo "Directory structure verified."

# -----------------------------
# 2️⃣ Copy ALL template files dynamically
# -----------------------------
if compgen -G "$TEMPLATE_DIR/*.TEMPLATE" > /dev/null; then
    for template_file in "$TEMPLATE_DIR/"*.TEMPLATE; do
        base_name=$(basename "$template_file" .TEMPLATE)
        target_file="$SCRIPT_DIR/$base_name"

        cp -f "$template_file" "$target_file"
        chmod +x "$target_file"

        echo "Installed $base_name"
    done
else
    echo "❌ No .TEMPLATE files found in $TEMPLATE_DIR"
    echo "Installation cannot proceed without templates."
    exit 1
fi

# -----------------------------
# 3️⃣ Ensure Python dependency
# -----------------------------
if ! python3 -c "import psutil" &> /dev/null; then
    echo "Installing required Python package: psutil"
    pip3 install --user psutil
else
    echo "psutil already installed."
fi

# -----------------------------
# 4️⃣ Configure cron job (09:00 and 15:00 daily)
# -----------------------------
CRON_JOB="0 9,15 * * * $SCRIPT_DIR/run_log_check.sh >> $LOG_DIR/cron.log 2>&1"

( crontab -l 2>/dev/null | grep -F "$SCRIPT_DIR/run_log_check.sh" ) || \
( crontab -l 2>/dev/null; echo "$CRON_JOB" ) | crontab -

echo "Cron job configured for 09:00 and 15:00 daily."

# -----------------------------
# 5️⃣ Completion
# -----------------------------
echo ""
echo "✅ AnchorPoint Monitoring installation complete!"
echo "Scripts directory: $SCRIPT_DIR"
echo "Logs directory: $LOG_DIR"
echo "Reports directory: $BASE_DIR/reports"
echo ""
