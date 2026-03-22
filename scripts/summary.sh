#!/bin/bash

# ===== LOAD CONFIG =====
CONFIG_FILE="$HOME/log-project/config/config.conf"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Config file not found: $CONFIG_FILE"
    exit 1
fi

source "$CONFIG_FILE"

# ===== CENTRAL SERVER CONFIG =====
CENTRAL_SERVER="brianhill@100.125.19.28"

# ===== HOST + DATE =====
HOSTNAME=$(hostname)
DATE=$(date +"%Y-%m-%d-%H%M%S")

# ===== REPORT DIRECTORY =====
REPORT_DIR="$BASE_REPORT_DIR/$HOSTNAME"
mkdir -p "$REPORT_DIR"

# ===== LOG FILES =====
LATEST_LOG=$(ls -t "$HOME/log-project/logs/${HOSTNAME}-monitor-"*.log 2>/dev/null | head -n1)

# ===== OUTPUT FILE PATHS =====
ALERT_LOG="$REPORT_DIR/alerts.log"
HISTORY_LOG="$REPORT_DIR/history.log"
DASHBOARD_LOG="$REPORT_DIR/dashboard.log"

SUMMARY_LOG="$REPORT_DIR/${HOSTNAME}-Summary-$DATE.log"
SUMMARY_HTML="$REPORT_DIR/${HOSTNAME}-Summary-$DATE.html"
TREND_FILE="$REPORT_DIR/${HOSTNAME}-trend.log"

# ===== RAW METRICS =====

CPU_LOAD=$(uptime | awk -F'load average:' '{ print $2 }' | cut -d',' -f1 | xargs)
CPU_LOAD=${CPU_LOAD:-0}

# ===== CPU USAGE =====
read cpu user nice system idle iowait irq softirq steal guest < /proc/stat
total1=$((user + nice + system + idle + iowait + irq + softirq + steal))
idle1=$idle

sleep 1

read cpu user nice system idle iowait irq softirq steal guest < /proc/stat
total2=$((user + nice + system + idle + iowait + irq + softirq + steal))
idle2=$idle

total_diff=$((total2 - total1))
idle_diff=$((idle2 - idle1))

CPU_USAGE=$(( (100 * (total_diff - idle_diff)) / total_diff ))

# ===== CPU STATUS =====
if [ "$CPU_USAGE" -ge "$CPU_THRESHOLD" ]; then
    CPU_STATUS="HIGH"
elif [ "$CPU_USAGE" -ge 50 ]; then
    CPU_STATUS="MEDIUM"
else
    CPU_STATUS="LOW"
fi

# Temperature
if command -v vcgencmd >/dev/null 2>&1; then
    TEMP=$(vcgencmd measure_temp 2>/dev/null | grep -o '[0-9]*\.[0-9]*')
else
    TEMP=0
fi
TEMP=${TEMP:-0}

# Memory
MEMORY_USAGE=$(free | awk '/Mem:/ { printf "%.0f", $3/$2*100 }')
MEMORY_USAGE=${MEMORY_USAGE:-0}

# Disk
DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
DISK_USAGE=${DISK_USAGE:-0}

# Disk + Memory Status
[ "$DISK_USAGE" -ge 90 ] && DISK_STATUS="HIGH" || DISK_STATUS="LOW"
[ "$MEMORY_USAGE" -ge 90 ] && MEM_STATUS="HIGH" || MEM_STATUS="LOW"

# Network
INTERFACE=$(ip route | grep default | awk '{print $5}' | head -n1)
RX_BYTES=$(cat /sys/class/net/${INTERFACE}/statistics/rx_bytes 2>/dev/null || echo 0)
TX_BYTES=$(cat /sys/class/net/${INTERFACE}/statistics/tx_bytes 2>/dev/null || echo 0)

RX_MB=$((RX_BYTES / 1024 / 1024))
TX_MB=$((TX_BYTES / 1024 / 1024))

sleep 1

RX_BYTES2=$(cat /sys/class/net/${INTERFACE}/statistics/rx_bytes 2>/dev/null || echo 0)
TX_BYTES2=$(cat /sys/class/net/${INTERFACE}/statistics/tx_bytes 2>/dev/null || echo 0)

RX_RATE=$(echo "scale=2; ($RX_BYTES2 - $RX_BYTES)/1024/1024" | bc)
TX_RATE=$(echo "scale=2; ($TX_BYTES2 - $TX_BYTES)/1024/1024" | bc)

# SSH
if systemctl is-active ssh >/dev/null 2>&1; then
    SSH_STATUS="active"
else
    SSH_STATUS="inactive"
fi

UPTIME_INFO=$(uptime -p)

# ===== RISK =====
OVERALL_RISK="LOW"

if (( CPU_USAGE > 85 )); then
    OVERALL_RISK="HIGH"
elif [ "$DISK_USAGE" -ge 90 ] || [ "$MEMORY_USAGE" -ge 90 ]; then
    OVERALL_RISK="HIGH"
elif [ "$SSH_STATUS" == "inactive" ]; then
    OVERALL_RISK="HIGH"
fi

# ===== ALERT =====
ALERT_LOG="$HOME/log-project/logs/alerts.log"

if [ "$OVERALL_RISK" == "HIGH" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') | ALERT | $HOSTNAME | CPU: $CPU_USAGE% | MEM: $MEMORY_USAGE% | DISK: $DISK_USAGE% | SSH: $SSH_STATUS" >> "$ALERT_LOG"
fi

# ===== SUMMARY =====
{
echo "AnchorPoint Monitoring"
echo "System Health Summary"
echo "Host: $HOSTNAME"
echo "Date: $DATE"
echo "----------------------------------"
echo "CPU Load: $CPU_LOAD"
echo "CPU Usage: $CPU_USAGE% ($CPU_STATUS)"
echo "Disk Usage: $DISK_USAGE% ($DISK_STATUS)"
echo "Memory Usage: $MEMORY_USAGE% ($MEM_STATUS)"
echo "Temperature: ${TEMP}°C"
echo "Uptime: $UPTIME_INFO"
echo "Network RX: $RX_MB MB"
echo "Network TX: $TX_MB MB"
echo "RX Rate: $RX_RATE MB/s"
echo "TX Rate: $TX_RATE MB/s"
echo "SSH Status: $SSH_STATUS"
echo "----------------------------------"
echo "Overall Risk Level: $OVERALL_RISK"
echo ""
echo "Executive Summary: System risk level is $OVERALL_RISK."
} > "$SUMMARY_LOG"

echo "Summary log created: $SUMMARY_LOG"

# ===== CENTRAL SYNC =====

ssh "$CENTRAL_SERVER" "mkdir -p ~/central-monitoring/$HOSTNAME"

scp "$SUMMARY_LOG" "$CENTRAL_SERVER:~/central-monitoring/$HOSTNAME/"

[ -f "$ALERT_LOG" ] && scp "$ALERT_LOG" "$CENTRAL_SERVER:~/central-monitoring/$HOSTNAME/"
[ -f "$HISTORY_LOG" ] && scp "$HISTORY_LOG" "$CENTRAL_SERVER:~/central-monitoring/$HOSTNAME/"
[ -f "$DASHBOARD_LOG" ] && scp "$DASHBOARD_LOG" "$CENTRAL_SERVER:~/central-monitoring/$HOSTNAME/"
