#!/bin/bash

BASE_DIR="$HOME/log-project"
SCRIPTS_DIR="$BASE_DIR/scripts"
LOG_DIR="$BASE_DIR/logs"

mkdir -p "$LOG_DIR"

HOSTNAME=$(hostname)
TIMESTAMP=$(date +"%Y-%m-%d-%H%M%S")

REPORT_FILE="$LOG_DIR/${HOSTNAME}-monitor-${TIMESTAMP}.log"

echo "📊 Collecting system metrics..."

# ==============================
# RUN ANALYZER
# ==============================
python3 "$SCRIPTS_DIR/log_analyzer.py" > "$REPORT_FILE"

echo "Monitoring report saved to:"
echo "$REPORT_FILE"

# ==============================
# RUN SUMMARY
# ==============================
SUMMARY_OUTPUT=$("$SCRIPTS_DIR/summary.sh")

echo "$SUMMARY_OUTPUT"

# Extract summary file path
SUMMARY_FILE=$(echo "$SUMMARY_OUTPUT" | grep -o '/.*Summary.*\.log')

# ==============================
# COPY TO CENTRAL MONITORING
# ==============================
CENTRAL_DIR="$HOME/central-monitoring/AP-Monitoring/$HOSTNAME"
mkdir -p "$CENTRAL_DIR"

if [ -f "$SUMMARY_FILE" ]; then
    cp "$SUMMARY_FILE" "$CENTRAL_DIR/"
fi

# ==============================
# RUN ALERTS
# ==============================
"$SCRIPTS_DIR/alerts-only.sh"

echo "✅ Monitoring run complete."
