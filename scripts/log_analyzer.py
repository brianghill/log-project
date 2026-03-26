#!/usr/bin/env python3
# log_analyzer.py
# Fully Python 3 compatible, host-aware, sends summaries to monitoring-reports/<hostname>

import os
import socket
import datetime

# ===== HOST INFO =====
HOSTNAME = socket.gethostname()
HOSTNAME_FQDN = socket.getfqdn()  # for logs if needed

# ===== DIRECTORIES =====
LOGS_DIR = os.path.expanduser("~/log-project/logs")
ALERTS_LOG_FILE = os.path.join(LOGS_DIR, "alerts.log")

# This is the folder we want per host on the local machine
CENTRAL_MONITORING_DIR = os.path.expanduser(f"~/monitoring-reports/{HOSTNAME}")
os.makedirs(CENTRAL_MONITORING_DIR, exist_ok=True)

# ===== TIMESTAMP =====
NOW = datetime.datetime.now(datetime.timezone.utc)
TIMESTAMP = NOW.strftime("%Y-%m-%d-%H%M%S")

# ===== FUNCTIONS =====
def parse_alerts(alerts_file):
    alerts = {}
    if not os.path.exists(alerts_file):
        return alerts

    with open(alerts_file, "r") as f:
        for line in f:
            line = line.strip()
            if line.startswith("🚨 CRITICAL DISK:"):
                alerts["disk"] = line.split(":")[1].strip()
            elif line.startswith("🚨 CRITICAL MEMORY:"):
                alerts["memory"] = line.split(":")[1].strip()
            elif line.startswith("🚨 CRITICAL CPU LOAD:"):
                alerts["cpu"] = line.split(":")[1].strip()
            elif line.startswith("🚨 CRITICAL NETWORK RX:"):
                alerts["network"] = line.split(":")[1].strip()
    return alerts

def write_summary(dir_path, timestamp, alerts):
    summary_file = os.path.join(dir_path, f"{HOSTNAME}-Summary-{timestamp}.log")
    with open(summary_file, "w") as f:
        f.write(f"==== SUMMARY CHECK {NOW.strftime('%a %b %d %H:%M:%S UTC %Y')} ====\n")
        f.write(f"HOST: {HOSTNAME} ({HOSTNAME_FQDN})\n\nSYSTEM ALERTS:\n")
        if not alerts:
            f.write("No critical alerts.\n")
        else:
            for key, val in alerts.items():
                f.write(f"{key.upper()}: {val}\n")
    return summary_file

def main():
    alerts = parse_alerts(ALERTS_LOG_FILE)
    summary_file = write_summary(CENTRAL_MONITORING_DIR, TIMESTAMP, alerts)
    print(f"✅ Summary written: {summary_file}")

if __name__ == "__main__":
    main()
