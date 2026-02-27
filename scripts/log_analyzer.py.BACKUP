#!/usr/bin/env python3

import os
import psutil
import datetime

# =====================================
# CONFIGURATION
# =====================================

BASE_DIR = os.path.expanduser("~/log-project")
LOG_DIR = os.path.join(BASE_DIR, "logs")
MAX_LOG_SIZE = 10 * 1024 * 1024  # 10MB

os.makedirs(LOG_DIR, exist_ok=True)

# =====================================
# DAILY LOG FILE NAME
# =====================================

today_str = datetime.datetime.now().strftime("%Y-%m-%d")
log_filename = f"health-{today_str}.log"
log_path = os.path.join(LOG_DIR, log_filename)

# =====================================
# SIZE ROTATION (10MB safeguard)
# =====================================

if os.path.exists(log_path) and os.path.getsize(log_path) >= MAX_LOG_SIZE:
    counter = 1
    while True:
        rotated_name = f"{log_filename}.{counter}"
        rotated_path = os.path.join(LOG_DIR, rotated_name)
        if not os.path.exists(rotated_path):
            os.rename(log_path, rotated_path)
            break
        counter += 1

# =====================================
# COLLECT METRICS
# =====================================

timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")

cpu_usage = round(psutil.cpu_percent(interval=1), 1)
ram_usage = round(psutil.virtual_memory().percent, 1)
disk_usage = round(psutil.disk_usage('/').percent, 1)

net_io = psutil.net_io_counters()
network_bytes = net_io.bytes_sent + net_io.bytes_recv
network_gb = round(network_bytes / (1024**3), 2)

# =====================================
# DETERMINE STATUS LEVEL
# =====================================

level = "INFO"

if cpu_usage > 85 or ram_usage > 85:
    level = "WARN"

if disk_usage > 90:
    level = "ERROR"

# =====================================
# STRUCTURED & ALIGNED LOG ENTRY
# =====================================
            
log_entry = (
    f"[{timestamp}] | "
    f"{level:<5} | "
    f"{'SYSTEM':<7} | "
    f"CPU={cpu_usage:<5}% | "
    f"RAM={ram_usage:<5}% | "
    f"DISK={disk_usage:<5}% | "
    f"NETWORK={network_gb}GB ({network_bytes} bytes)\n"
)

with open(log_path, "a") as f:
    f.write(log_entry)

#!/bin/bash

# ==============================
# SYSTEM INFORMATION COLLECTION
# ==============================

HOSTNAME=$(hostname)
IP_ADDRESS=$(hostname -I | awk '{print $1}')
OS_VERSION=$(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '"')
DATE=$(date)
LOAD=$(uptime | awk -F'load average:' '{print $2}')
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}')
MEMORY_USAGE=$(free -h | awk '/Mem:/ {print $3 " / " $2}')

REPORT_DIR="$HOME/log-project"
REPORT_FILE="$REPORT_DIR/summary.txt"

mkdir -p $REPORT_DIR

# ==============================
# GENERATE STRUCTURED REPORT
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

echo "Service Health:" >> $REPORT_FILE
systemctl --failed >> $REPORT_FILE
echo "" >> $REPORT_FILE

echo "Resource Status:" >> $REPORT_FILE
echo "Load Average:$LOAD" >> $REPORT_FILE
echo "Disk Usage (root): $DISK_USAGE" >> $REPORT_FILE
echo "Memory Usage: $MEMORY_USAGE" >> $REPORT_FILE
echo "" >> $REPORT_FILE

echo "Security (Failed SSH Logins - Last 24h):" >> $REPORT_FILE
grep "Failed password" /var/log/auth.log | tail -n 10 >> $REPORT_FILE
echo "" >> $REPORT_FILE

echo "Recent System Errors:" >> $REPORT_FILE
grep -i "error" /var/log/syslog | tail -n 10 >> $REPORT_FILE
echo "" >> $REPORT_FILE
