#!/usr/bin/env python3

import os
from datetime import datetime

# ---- CONFIG ----
CLIENT_NAME = "ClientA"
REPORTS_DIR = "../reports/clients/ClientA"

# ---- Example metrics (replace with your actual daily collection logic) ----
metrics = {
    "CPU_AVG": 66.11,
    "CPU_PEAK": 94.12,
    "RAM_AVG": 61.91,
    "RAM_PEAK": 89.25,
    "DISK_AVG": 43.91,
    "DISK_PEAK": 73.56,
    "NETWORK_TOTAL": 545947261  # in bytes
}

# Convert Network from bytes → GB
network_gb = metrics["NETWORK_TOTAL"] / (1024**3)  # Bytes to GB

# ---- STATUS COLOR LOGIC ----
def get_status(value, warning, critical):
    if value >= critical:
        return "🔴"
    elif value >= warning:
        return "🟡"
    else:
        return "🟢"

cpu_status = get_status(metrics["CPU_AVG"], 70, 85)
ram_status = get_status(metrics["RAM_AVG"], 70, 85)
disk_status = get_status(metrics["DISK_AVG"], 50, 80)
network_status = "🟢"  # Usually network status stays green unless you have thresholds

# ---- EXECUTIVE SUMMARY ----
def generate_executive_summary(cpu_avg, cpu_peak, ram_avg, ram_peak, disk_avg, disk_peak, network_gb):
    summary = []

    if cpu_peak > 85:
        summary.append(f"High CPU utilization spikes were observed during the reporting period (peak {cpu_peak:.2f}%).")
    else:
        summary.append(f"CPU utilization remained within normal ranges (peak {cpu_peak:.2f}%).")

    if ram_peak > 85:
        summary.append(f"Elevated memory usage detected (peak {ram_peak:.2f}%).")
    else:
        summary.append(f"Memory usage remained healthy (peak {ram_peak:.2f}%).")

    summary.append(f"Disk utilization averaged {disk_avg:.2f}% with a peak of {disk_peak:.2f}%.")
    summary.append(f"Network usage totaled {network_gb:.2f} GB for the day.")

    return "\n\n".join(summary)

# ---- GENERATE REPORT ----
today = datetime.today().strftime("%Y-%m-%d")
report_filename = f"{REPORTS_DIR}/daily_report_{today}.md"

report_content = f"""# Daily System Health Report

**Client:** {CLIENT_NAME}
**Date:** {today}

---

## Resource Summary

| Metric | Avg | Peak | Current | Status |
|--------|-----|------|---------|--------|
| CPU Usage | {metrics['CPU_AVG']:.2f}% | {metrics['CPU_PEAK']:.2f}% | {metrics['CPU_AVG']:.2f}% | {cpu_status} |
| RAM Usage | {metrics['RAM_AVG']:.2f}% | {metrics['RAM_PEAK']:.2f}% | {metrics['RAM_AVG']:.2f}% | {ram_status} |
| Disk Usage | {metrics['DISK_AVG']:.2f}% | {metrics['DISK_PEAK']:.2f}% | {metrics['DISK_AVG']:.2f}% | {disk_status} |
| Network (Total GB) | {network_gb:.2f} | - | - | {network_status} |

---

## Raw Metrics (For Weekly Aggregation)

CPU Usage: {metrics['CPU_AVG']:.2f}%
RAM Usage: {metrics['RAM_AVG']:.2f}%
Disk Usage: {metrics['DISK_AVG']:.2f}%
Network Total GB: {network_gb:.2f}

---

## Executive Summary

{generate_executive_summary(metrics['CPU_AVG'], metrics['CPU_PEAK'],
                            metrics['RAM_AVG'], metrics['RAM_PEAK'],
                            metrics['DISK_AVG'], metrics['DISK_PEAK'],
                            network_gb)}
"""

os.makedirs(REPORTS_DIR, exist_ok=True)
with open(report_filename, "w") as f:
    f.write(report_content)

print(f"Daily report generated: {report_filename}")
