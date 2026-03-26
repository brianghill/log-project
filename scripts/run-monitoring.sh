#!/bin/bash
# =============================================
# Run system monitoring and generate summaries
# =============================================

# Set thresholds (can be overridden by environment variables)
DISK_THRESHOLD=${DISK_CRIT_OVERRIDE:-80}
MEM_THRESHOLD=${MEM_CRIT_OVERRIDE:-80}
CPU_THRESHOLD=${LOAD_CRIT_OVERRIDE:-1.0}
NETWORK_THRESHOLD=${NETWORK_CRIT_OVERRIDE:-10000}  # bytes/sec

# Detect hostname dynamically
HOSTNAME=$(hostname -s)

# Paths
LOG_DIR=~/log-project/logs
SUMMARY_DIR=~/central-monitoring/AP-Monitoring/$HOSTNAME
SUMMARY_FILE="$SUMMARY_DIR/$HOSTNAME-Summary-$(date +%Y-%m-%d-%H%M%S).log"

# Ensure directories exist
mkdir -p "$LOG_DIR"
mkdir -p "$SUMMARY_DIR"

# Run alerts-only check
~/log-project/scripts/alerts-only.sh

# Generate monitoring report
echo "📊 Collecting system metrics..."
REPORT_FILE="$LOG_DIR/$HOSTNAME-monitor-$(date +%Y-%m-%d-%H%M%S).log"
~/log-project/scripts/log_analyzer.py > "$REPORT_FILE"

echo "Monitoring report saved to:"
echo "$REPORT_FILE"

# Run summary
~/log-project/scripts/summary.sh "$SUMMARY_FILE"

echo "Summary log created: $SUMMARY_FILE"
echo "✅ Alert check complete. Log: $LOG_DIR/alerts.log"
