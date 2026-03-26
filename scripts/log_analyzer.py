#!/usr/bin/env python3
# log_analyzer.py
# Analyzes collected system metrics and writes summary logs per host.

import os
import socket
import datetime

# ===== CONFIG =====
CENTRAL_MONITORING_DIR = os.path.expanduser("~/central-monitoring/AP-Monitoring")
LOGS_DIR = os.path.expanduser("~/log-project/logs")
METRICS_FILE_PATTERN = "dev-logproject-monitor-*.log"  # fallback pattern if needed
ALERTS_LOG_FILE = os.path.join(LOGS_DIR, "alerts.log")

# ===== HOST INFO =====
HOSTNAME = socket.gethostname()           # local hostname
HOSTNAME_FQDN = socket.getfqdn()          # fully qualified domain name

# ===== TIMESTAMP =====
NOW = datetime.datetime.utcnow()
TIMESTAMP = NOW.strftime("%Y-%m-%d-%H%M%S")

# ===== DIRECTORIES =====
host_dir = os.path.join(CENTRAL_MONITORING_DIR, HOSTNAME)
os.makedirs(host_dir, exist_ok=True)

# ===== FUNCTIONS =====
def parse_alerts(alerts_file):
    """Parse alerts.log for the latest system metrics."""
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

def write_summary(host_dir, timestamp, alerts):
    """Write a per-host summary log in the central monitoring folder."""
    summary_file = os.path.join(host_dir, f"{HOSTNAME}-Summary-{timestamp}.log")
    with open(summary_file, "w") as f:
        f.write(f"==== SUMMARY CHECK {NOW.strftime('%a %b %d %H:%M:%S UTC %Y')} ====\n")
        f.write(f"HOST: {HOSTNAME} ({HOSTNAME_FQDN})\n")
        f.write("\nSYSTEM ALERTS:\n")
        if not alerts:
            f.write("No critical alerts.\n")
        else:
            for key, val in alerts.items():
                f.write(f"{key.upper()}: {val}\n")
    return summary_file

def main():
    # Parse alerts
    alerts = parse_alerts(ALERTS_LOG_FILE)

    # Write summary
    summary_file = write_summary(host_dir, TIMESTAMP, alerts)
    print(f"✅ Summary written: {summary_file}")

if __name__ == "__main__":
    main()
