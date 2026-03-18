#!/bin/bash

# ===== LOAD CONFIG =====
CONFIG_FILE="$HOME/log-project/config/config.conf"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Config file not found: $CONFIG_FILE"
    exit 1
fi

source "$CONFIG_FILE"

# ===== CENTRAL SERVER CONFIG =====
CENTRAL_SERVER="brianhill@dev-logproject"

# ===== HOST + DATE =====
HOSTNAME=$(hostname)
DATE=$(date +"%Y-%m-%d-%H%M%S")

# ===== REPORT DIRECTORY =====
REPORT_DIR="$BASE_REPORT_DIR/$HOSTNAME"
mkdir -p "$REPORT_DIR"

# ===== LOG FILES =====
LATEST_LOG=$(ls -t "$HOME/log-project/logs/${HOSTNAME}-monitor-"*.log 2>/dev/null | head -n1)

# ===== OUTPUT FILE PATHS =====
ALERT_LOG="$REPORT_DIR/$ALERT_LOG"
HISTORY_LOG="$REPORT_DIR/$HISTORY_LOG"
DASHBOARD_LOG="$REPORT_DIR/$DASHBOARD_LOG"

SUMMARY_LOG="$REPORT_DIR/${HOSTNAME}-Summary-$DATE.log"
SUMMARY_HTML="$REPORT_DIR/${HOSTNAME}-Summary-$DATE.html"
TREND_FILE="$REPORT_DIR/${HOSTNAME}-trend.log"

# ===== RAW METRICS =====

# CPU Load (1 min average)
CPU_LOAD=$(uptime | awk -F'load average:' '{ print $2 }' | cut -d',' -f1 | xargs)
CPU_LOAD=${CPU_LOAD:-0}

# CPU Usage %
if command -v mpstat >/dev/null 2>&1; then
    CPU_USAGE=$(mpstat 1 1 | awk '/Average/ {usage=100-$12} END {printf "%.1f", usage}')
elif command -v top >/dev/null 2>&1; then
    CPU_USAGE=$(top -bn1 | awk '/Cpu\(s\)/ {print 100 - $8}')
    CPU_USAGE=$(printf "%.1f" $CPU_USAGE)
else
    CPU_USAGE=0
fi

# CPU Temperature
if command -v vcgencmd >/dev/null 2>&1; then
    TEMP=$(vcgencmd measure_temp 2>/dev/null | grep -o '[0-9]*\.[0-9]*')
else
    TEMP=0
fi
TEMP=${TEMP:-0}

# Memory Usage %
MEMORY_USAGE=$(free | awk '/Mem:/ { printf "%.0f", $3/$2*100 }')
MEMORY_USAGE=${MEMORY_USAGE:-0}

# Disk Usage %
DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
DISK_USAGE=${DISK_USAGE:-0}

# Network Usage
INTERFACE=$(ip route | grep default | awk '{print $5}' | head -n1)
RX_BYTES=$(cat /sys/class/net/${INTERFACE}/statistics/rx_bytes 2>/dev/null || echo 0)
TX_BYTES=$(cat /sys/class/net/${INTERFACE}/statistics/tx_bytes 2>/dev/null || echo 0)

RX_MB=$((RX_BYTES / 1024 / 1024))
TX_MB=$((TX_BYTES / 1024 / 1024))

# Network rate (MB/s)
sleep 1
RX_BYTES2=$(cat /sys/class/net/${INTERFACE}/statistics/rx_bytes 2>/dev/null || echo 0)
TX_BYTES2=$(cat /sys/class/net/${INTERFACE}/statistics/tx_bytes 2>/dev/null || echo 0)

RX_RATE=$(echo "scale=2; ($RX_BYTES2 - $RX_BYTES)/1024/1024" | bc)
TX_RATE=$(echo "scale=2; ($TX_BYTES2 - $TX_BYTES)/1024/1024" | bc)

# SSH Status
if systemctl is-active ssh >/dev/null 2>&1; then
    SSH_STATUS="active"
else
    SSH_STATUS="inactive"
fi

# Uptime
UPTIME_INFO=$(uptime -p)

# ===== RISK LEVEL CALCULATION =====
OVERALL_RISK="LOW"
if [ "$CPU_USAGE" != "0" ] && (( $(echo "$CPU_USAGE > 85" | bc -l) )); then
    OVERALL_RISK="HIGH"
elif [ "$DISK_USAGE" -ge 90 ] || [ "$MEMORY_USAGE" -ge 90 ]; then
    OVERALL_RISK="HIGH"
elif [ "$SSH_STATUS" == "inactive" ]; then
    OVERALL_RISK="HIGH"
fi

# ===== WRITE SUMMARY LOG =====
{
echo "AnchorPoint Monitoring"
echo "System Health Summary"
echo "Host: $HOSTNAME"
echo "Date: $DATE"
echo "----------------------------------"
echo "CPU Load: $CPU_LOAD (LOW)"
echo "CPU Usage: $CPU_USAGE% (LOW)"
echo "Disk Usage: $DISK_USAGE% (LOW)"
echo "Memory Usage: $MEMORY_USAGE% (LOW)"
echo "Temperature: ${TEMP}°C (LOW)"
echo "Uptime: $UPTIME_INFO"
echo "Network RX: $RX_MB MB"
echo "Network TX: $TX_MB MB"
echo "RX Rate: $RX_RATE MB/s"
echo "TX Rate: $TX_RATE MB/s"
echo "SSH Status: $SSH_STATUS (LOW)"
echo "----------------------------------"
echo "Overall Risk Level: $OVERALL_RISK"
echo ""
echo "Executive Summary: All monitored systems are currently operating at risk level: $OVERALL_RISK."
echo "Recommendations: Check any metrics flagged as HIGH or CRITICAL."
} > "$SUMMARY_LOG"

echo "Summary log created: $SUMMARY_LOG"

# ===== CENTRAL SYNC =====

CENTRAL_SERVER="brianhill@dev-logproject"

# Create directory on central server
ssh "$CENTRAL_SERVER" "mkdir -p ~/central-monitoring/$HOSTNAME"

# Copy summary log
scp "$SUMMARY_LOG" "$CENTRAL_SERVER:~/central-monitoring/$HOSTNAME/"

# Copy optional logs if they exist
[ -f "$ALERT_LOG" ] && scp "$ALERT_LOG" "$CENTRAL_SERVER:~/central-monitoring/$HOSTNAME/"
[ -f "$HISTORY_LOG" ] && scp "$HISTORY_LOG" "$CENTRAL_SERVER:~/central-monitoring/$HOSTNAME/"
[ -f "$DASHBOARD_LOG" ] && scp "$DASHBOARD_LOG" "$CENTRAL_SERVER:~/central-monitoring/$HOSTNAME/"
