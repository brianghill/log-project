#!/usr/bin/env python3

import os
import datetime
import re

BASE_DIR = os.path.expanduser("~/log-project")
LOG_DIR = os.path.join(BASE_DIR, "logs")
REPORT_DIR = os.path.join(BASE_DIR, "reports")

os.makedirs(REPORT_DIR, exist_ok=True)

today_str = datetime.datetime.now().strftime("%Y-%m-%d")
log_file = os.path.join(LOG_DIR, f"health-{today_str}.log")
report_file = os.path.join(REPORT_DIR, f"summary-{today_str}.txt")

if not os.path.exists(log_file):
    print("No log file for today.")
    exit()

cpu_values = []
ram_values = []
disk_values = []
network_values = []

with open(log_file, "r") as f:
    for line in f:
        cpu = re.search(r"CPU=([\d.]+)", line)
        ram = re.search(r"RAM=([\d.]+)", line)
        disk = re.search(r"DISK=([\d.]+)", line)
        net = re.search(r"\((\d+) bytes\)", line)

        if cpu:
            cpu_values.append(float(cpu.group(1)))
        if ram:
            ram_values.append(float(ram.group(1)))
        if disk:
            disk_values.append(float(disk.group(1)))
        if net:
            network_values.append(int(net.group(1)))

if not cpu_values:
    print("No valid data found.")
    exit()

avg_cpu = round(sum(cpu_values) / len(cpu_values), 2)
max_cpu = max(cpu_values)

avg_ram = round(sum(ram_values) / len(ram_values), 2)
max_ram = max(ram_values)

max_disk = max(disk_values)

network_used = network_values[-1] - network_values[0]
network_used_gb = round(network_used / (1024**3), 2)

summary = f"""
SYSTEM DAILY SUMMARY - {today_str}
-----------------------------------

CPU:
  Average: {avg_cpu}%
  Peak:    {max_cpu}%

RAM:
  Average: {avg_ram}%
  Peak:    {max_ram}%

Disk:
  Peak Usage: {max_disk}%

Network:
  Data Transferred Today: {network_used_gb} GB
  ({network_used} bytes)

-----------------------------------
Generated automatically by daily_summary.py
"""

with open(report_file, "w") as f:
    f.write(summary)

print("Daily summary generated.")
