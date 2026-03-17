#!/bin/bash

# ===== HOST + DATE =====
HOSTNAME=$(hostname)
DATE=$(date +"%Y-%m-%d-%H%M%S")

# ===== DIRECTORIES =====
BASE_DIR="$HOME/log-project"
OUTPUT_DIR="$BASE_DIR/logs"
OUTPUT_FILE="$OUTPUT_DIR/${HOSTNAME}-monitor-$DATE.log"

mkdir -p "$OUTPUT_DIR"

{
echo "=================================================="
echo "AnchorPoint Monitoring - Raw System Report"
echo "Host: $HOSTNAME"
echo "Date: $DATE"
echo "=================================================="
echo ""

# ----- STRUCTURED METRICS -----

# CPU Load (1 minute average)
CPU_LOAD=$(uptime | awk -F'load average:' '{ print $2 }' | cut -d',' -f1 | xargs)

CPU_USAGE=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage}')
CPU_USAGE=$(printf "%.1f" $CPU_USAGE)

echo "CPU Load: $CPU_LOAD"
echo "CPU Usage: $CPU_USAGE%"

# CPU Temperature
if command -v vcgencmd >/dev/null 2>&1; then
    TEMP=$(vcgencmd measure_temp 2>/dev/null | grep -o '[0-9]*\.[0-9]*')
else
    TEMP=0
fi

TEMP=${TEMP:-0}
echo "CPU Temperature: ${TEMP}°C"

# Memory Usage %
MEMORY_USAGE=$(free | awk '/Mem:/ { printf("%.0f"), $3/$2 * 100 }')
echo "Memory Usage: $MEMORY_USAGE%"

# Root Disk Usage %
DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
echo "Disk Usage: $DISK_USAGE%"

# Network Usage
INTERFACE=$(ip route | grep default | awk '{print $5}' | head -n1)

RX_BYTES=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes)
TX_BYTES=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes)

RX_MB=$((RX_BYTES / 1024 / 1024))
TX_MB=$((TX_BYTES / 1024 / 1024))

sleep 1

RX_BYTES2=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes)
TX_BYTES2=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes)

RX_RATE=$(echo "scale=2; ($RX_BYTES2 - $RX_BYTES) / 1024 / 1024" | bc)
TX_RATE=$(echo "scale=2; ($TX_BYTES2 - $TX_BYTES) / 1024 / 1024" | bc)

echo "Network RX: $RX_MB MB"
echo "Network TX: $TX_MB MB"
echo "RX Rate: $RX_RATE MB/s"
echo "TX Rate: $TX_RATE MB/s"

# SSH Service Status
SSH_STATUS=$(systemctl is-active ssh 2>/dev/null || echo "unknown")
echo "SSH Status: $SSH_STATUS"

echo ""
echo "----- Detailed Disk Table -----"
df -h

} > "$OUTPUT_FILE"

echo "Monitoring report saved to:"
echo "$OUTPUT_FILE"
