#!/bin/bash

# ==============================
# SYSTEM INFORMATION
# ==============================

HOSTNAME=$(hostname)
IP_ADDRESS=$(hostname -I | awk '{print $1}')
OS_VERSION=$(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '"')
DATE=$(date)

LOAD=$(uptime | awk -F'load average:' '{print $2}')
DISK_PERCENT=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
MEMORY_PERCENT=$(free | awk '/Mem:/ {printf("%.0f"), $3/$2 * 100}')

FAILED_SERVICES=$(systemctl --failed --no-legend | wc -l)
FAILED_SSH=$(grep "Failed password" /var/log/auth.log | wc -l)

REPORT_DIR="$HOME/log-project"
REPORT_FILE="$REPORT_DIR/summary.txt"

mkdir -p $REPORT_DIR

# ==============================
# THRESHOLD LOGIC
# ==============================

DISK_STATUS="OK"
MEMORY_STATUS="OK"
SERVICE_STATUS="OK"
SSH_STATUS="OK"

if [ "$DISK_PERCENT" -gt 85 ]; then
    DISK_STATUS="WARNING"
fi

if [ "$MEMORY_PERCENT" -gt 80 ]; then
    MEMORY_STATUS="WARNING"
fi

if [ "$FAILED_SERVICES" -gt 0 ]; then
    SERVICE_STATUS="CRITICAL"
fi

if [ "$FAILED_SSH" -gt 20 ]; then
    SSH_STATUS="WARNING"
fi

# ==============================
# GENERATE REPORT
# ==============================

echo "========================================" > $REPORT_FILE
echo "System Monitoring Report" >> $REPORT_FILE
echo "========================================" >> $REPORT_FILE
echo "Hostname: $HOSTNAME" >> $REPORT_FILE
echo "IP Address: $IP_ADDRESS" >> $REPORT_FILE
echo "Operating System: $OS_VERSION" >> $REPORT_FILE
echo "Report Generated: $DATE" >> $REPORT_FILE
echo "========================================" >> $REPORT_FILE
echo "" >> $REPORT_FILE

echo "Disk Usage: $DISK_PERCENT% [$DISK_STATUS]" >> $REPORT_FILE
echo "Memory Usage: $MEMORY_PERCENT% [$MEMORY_STATUS]" >> $REPORT_FILE
echo "Failed Services: $FAILED_SERVICES [$SERVICE_STATUS]" >> $REPORT_FILE
echo "Failed SSH Attempts: $FAILED_SSH [$SSH_STATUS]" >> $REPORT_FILE

# ==============================
# SEND REPORT BACK TO MONITOR
# ==============================

scp $REPORT_FILE brian@YOUR_MAC_IP:/Users/brian/monitoring-reports/$HOSTNAME/
