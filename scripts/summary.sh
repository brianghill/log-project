#!/bin/bash
# =============================================
# dev-logproject / Monitoring Summary Script
# =============================================
# Generates a summary log from monitoring reports.
# Maintains historical summaries in central-monitoring.
# Dynamically names folders/files based on hostname.
# =============================================

# ----------------------------
# Arguments / Config
# ----------------------------
SUMMARY_FILE="$1"

if [ -z "$SUMMARY_FILE" ]; then
    echo "Usage: $0 <summary-file-path>"
    exit 1
fi

# Dynamic hostname
HOSTNAME=$(hostname -s)

# Paths
LOG_DIR=~/log-project/logs
SUMMARY_DIR=$(dirname "$SUMMARY_FILE")

# Ensure summary directory exists
mkdir -p "$SUMMARY_DIR"

# ----------------------------
# Collect Latest Monitoring Report
# ----------------------------
LATEST_REPORT=$(ls -1t "$LOG_DIR"/*-monitor-*.log 2>/dev/null | head -n 1)

if [ -z "$LATEST_REPORT" ]; then
    echo "No monitoring reports found in $LOG_DIR" > "$SUMMARY_FILE"
    exit 0
fi

# ----------------------------
# Generate Summary Header
# ----------------------------
echo "==========================================" > "$SUMMARY_FILE"
echo " MONITORING SUMMARY - $HOSTNAME " >> "$SUMMARY_FILE"
echo " Generated: $(date) " >> "$SUMMARY_FILE"
echo " Source Report: $LATEST_REPORT " >> "$SUMMARY_FILE"
echo "==========================================" >> "$SUMMARY_FILE"
echo "" >> "$SUMMARY_FILE"

# ----------------------------
# Parse and Summarize Alerts
# ----------------------------
# Check if alerts exist
ALERT_LOG="$LOG_DIR/alerts.log"

if [ -f "$ALERT_LOG" ] && [ -s "$ALERT_LOG" ]; then
    echo "Recent Alerts:" >> "$SUMMARY_FILE"
    grep -E "🚨|CRITICAL" "$ALERT_LOG" | tail -n 20 >> "$SUMMARY_FILE"
    echo "" >> "$SUMMARY_FILE"
else
    echo "No recent alerts." >> "$SUMMARY_FILE"
    echo "" >> "$SUMMARY_FILE"
fi

# ----------------------------
# Extract Metrics from Latest Report
# ----------------------------
echo "System Metrics (Latest Report):" >> "$SUMMARY_FILE"
grep -E "DISK|MEMORY|CPU|NETWORK" "$LATEST_REPORT" >> "$SUMMARY_FILE"
echo "" >> "$SUMMARY_FILE"

# ----------------------------
# Optional: Additional Stats
# ----------------------------
if grep -q "CRITICAL" "$LATEST_REPORT"; then
    echo "⚠️ Some metrics are critical. Review immediately!" >> "$SUMMARY_FILE"
fi

# ----------------------------
# Keep Historical Summaries Short (Optional)
# ----------------------------
# Max 50 summaries per host
MAX_SUMMARIES=50
cd "$SUMMARY_DIR" || exit
SUMMARY_COUNT=$(ls -1 $HOSTNAME-Summary-*.log 2>/dev/null | wc -l)
if [ "$SUMMARY_COUNT" -gt "$MAX_SUMMARIES" ]; then
    OLDEST=$(ls -1t $HOSTNAME-Summary-*.log | tail -n +$(($MAX_SUMMARIES + 1)))
    rm -f $OLDEST
fi

echo "✅ Summary written: $SUMMARY_FILE"
