#!/bin/bash
# =========================================
# run-monitoring.sh
# Full monitoring pipeline: metrics, alerts, summary
# =========================================

echo "📊 Collecting system metrics..."

# Apply overrides if present
DISK_CRIT_OVERRIDE=${DISK_CRIT_OVERRIDE:-80}
MEM_CRIT_OVERRIDE=${MEM_CRIT_OVERRIDE:-80}
LOAD_CRIT_OVERRIDE=${LOAD_CRIT_OVERRIDE:-5}
NETWORK_CRIT_OVERRIDE=${NETWORK_CRIT_OVERRIDE:-100000}

# Run alerts collection
"$HOME/log-project/scripts/alerts-only.sh"

# Run summary creation
"$HOME/log-project/scripts/summary.sh"

# Create monitoring report from alerts
REPORT_FILE="$HOME/log-project/logs/dev-logproject-monitor-$(date +%Y-%m-%d-%H%M%S).log"
cp "$HOME/log-project/logs/alerts.log" "$REPORT_FILE"
echo "Monitoring report saved to:"
echo "$REPORT_FILE"

# Copy all summary logs to central monitoring (dev VM)
CENTRAL_MONITOR_DIR="$HOME/central-monitoring/AP-Monitoring/dev-logproject"
mkdir -p "$CENTRAL_MONITOR_DIR"
cp "$HOME/monitoring-reports/dev-logproject/dev-logproject-Summary-"*.log "$CENTRAL_MONITOR_DIR/"

echo "✅ Alert check complete. Log: $HOME/log-project/logs/alerts.log"
