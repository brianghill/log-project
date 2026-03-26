#!/bin/bash
# =========================================
# summary.sh
# Generates a summary report of system alerts
# =========================================

MONITORING_LOG_DIR="$HOME/log-project/logs"
SUMMARY_DIR="$HOME/monitoring-reports/dev-logproject"

mkdir -p "$SUMMARY_DIR"

# Generate timestamped summary filename
SUMMARY_FILE="$SUMMARY_DIR/dev-logproject-Summary-$(date +%Y-%m-%d-%H%M%S).log"

echo "Summary for dev-logproject at $(date -u)" > "$SUMMARY_FILE"
echo "=========================================" >> "$SUMMARY_FILE"

# Loop through latest alerts
ALERT_LINES=$(tail -n 50 "$MONITORING_LOG_DIR/alerts.log")  # last 50 lines

if [[ -z "$ALERT_LINES" ]]; then
    echo "No alerts in the last run." >> "$SUMMARY_FILE"
else
    echo "$ALERT_LINES" >> "$SUMMARY_FILE"
fi

# Extract latest CPU, Disk, Memory metrics for easier summary
LAST_DISK=$(grep -E 'DISK' "$MONITORING_LOG_DIR/alerts.log" | tail -1 | awk '{print $3}')
LAST_MEM=$(grep -E 'MEMORY' "$MONITORING_LOG_DIR/alerts.log" | tail -1 | awk '{print $3}')
LAST_CPU=$(grep -E 'CPU' "$MONITORING_LOG_DIR/alerts.log" | tail -1 | awk '{print $4}')
LAST_NET=$(grep -E 'NETWORK' "$MONITORING_LOG_DIR/alerts.log" | tail -1 | awk '{print $4}')

# Integer checks
[[ "$LAST_DISK" =~ ^[0-9]+$ ]] || LAST_DISK=0
[[ "$LAST_MEM" =~ ^[0-9]+$ ]] || LAST_MEM=0
[[ "$LAST_CPU" =~ ^[0-9.]+$ ]] || LAST_CPU=0

echo "" >> "$SUMMARY_FILE"
echo "Latest Metrics:" >> "$SUMMARY_FILE"
echo "Disk Usage: $LAST_DISK%" >> "$SUMMARY_FILE"
echo "Memory Usage: $LAST_MEM%" >> "$SUMMARY_FILE"
echo "CPU Load: $LAST_CPU" >> "$SUMMARY_FILE"
[[ -n "$LAST_NET" ]] && echo "Network RX: $LAST_NET bytes/sec" >> "$SUMMARY_FILE"

# Determine status
THRESHOLD_DISK=80
THRESHOLD_MEM=80
THRESHOLD_CPU=5

STATUS="OK"
if [ "$LAST_DISK" -ge "$THRESHOLD_DISK" ] || [ "$LAST_MEM" -ge "$THRESHOLD_MEM" ] || (( $(echo "$LAST_CPU >= $THRESHOLD_CPU" | bc -l) )); then
    STATUS="CRITICAL"
fi

echo "" >> "$SUMMARY_FILE"
echo "Overall Status: $STATUS" >> "$SUMMARY_FILE"

echo "Summary log created: $SUMMARY_FILE"

# Copy summary to central monitoring folder (dev VM)
CENTRAL_MONITOR_DIR="$HOME/central-monitoring/AP-Monitoring/dev-logproject"
mkdir -p "$CENTRAL_MONITOR_DIR"
cp "$SUMMARY_FILE" "$CENTRAL_MONITOR_DIR/"
