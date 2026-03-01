#!/bin/bash

HOSTNAME=$(hostname)
DATE=$(date +"%Y-%m-%d-%H%M%S")
OUTPUT_DIR="/home/brianhill/monitoring-reports/$HOSTNAME"
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
echo "CPU Load: $CPU_LOAD"

# Memory Usage
MEMORY_USAGE=$(free | awk '/Mem:/ { printf("%.0f"), $3/$2 * 100 }')
echo "Memory Usage: $MEMORY_USAGE%"

# Root Disk Usage
DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
echo "Disk Usage: $DISK_USAGE%"

# SSH Service Status
SSH_STATUS=$(systemctl is-active ssh 2>/dev/null || echo "unknown")
echo "SSH Status: $SSH_STATUS"

echo ""
echo "----- Detailed Disk Table -----"
df -h

} > "$OUTPUT_FILE"

echo "Monitoring report saved to:"
echo "$OUTPUT_FILE"
