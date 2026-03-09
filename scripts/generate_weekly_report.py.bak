#!/usr/bin/env python3

import os
from datetime import datetime

# ---- CONFIG ----
CLIENT_NAME = "ClientA"
REPORTS_DIR = "../reports/clients/ClientA"

# ---- Example metrics for the week (replace with actual weekly aggregation logic) ----
weekly_metrics = {
    "CPU_AVG": 54.25,
    "CPU_PEAK": 94.84,
    "RAM_AVG": 57.45,
    "RAM_PEAK": 82.29,
    "DISK_AVG": 40.64,
    "DISK_PEAK": 69.94,
    "NETWORK_TOTAL": 547482442  # in bytes
}

# Convert Network bytes → GB
network_gb = weekly_metrics["NETWORK_TOTAL"] / (1024**3)  # Bytes → GB

# ---- STATUS COLOR LOGIC ----
def get_status(value, warning, critical):
    if value >= critical:
        return "🔴"
    elif value >= warning:
        return "🟡"
    else:
        return "🟢"

cpu_status = get_status(weekly_metrics["CPU_AVG"], 70, 100)
ram_status = get_status(weekly_metrics["RAM_AVG"], 70, 85)
disk_status = get_status(weekly_metrics["DISK_AVG"], 50, 80)
network_status = "🟢"

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
    summary.append(f"Network usage totaled {network_gb:.2f} GB for the week.")

    return "\n\n".join(summary)

# ---- GENERATE REPORT ----
today = datetime.today().strftime("%Y-%m-%d")
report_filename = f"{REPORTS_DIR}/weekly_report_{today}.md"

report_content = f"""# Weekly System Health Report

**Client:** {CLIENT_NAME}
**Week Ending:** {today}

---

## Resource Summary

| Metric | Weekly Avg | Weekly Peak | Status |
|--------|------------|-------------|--------|
| CPU | {weekly_metrics['CPU_AVG']:.2f}% | {weekly_metrics['CPU_PEAK']:.2f}% | {cpu_status} |
| RAM | {weekly_metrics['RAM_AVG']:.2f}% | {weekly_metrics['RAM_PEAK']:.2f}% | {ram_status} |
| Disk | {weekly_metrics['DISK_AVG']:.2f}% | {weekly_metrics['DISK_PEAK']:.2f}% | {disk_status} |
| Network (Total GB) | {network_gb:.2f} | - | {network_status} |

---

## Raw Metrics (For Reference)

CPU Avg: {weekly_metrics['CPU_AVG']:.2f}%
CPU Peak: {weekly_metrics['CPU_PEAK']:.2f}%
RAM Avg: {weekly_metrics['RAM_AVG']:.2f}%
RAM Peak: {weekly_metrics['RAM_PEAK']:.2f}%
Disk Avg: {weekly_metrics['DISK_AVG']:.2f}%
Disk Peak: {weekly_metrics['DISK_PEAK']:.2f}%
Network Total GB: {network_gb:.2f}

---

## Executive Summary

{generate_executive_summary(
    weekly_metrics['CPU_AVG'], weekly_metrics['CPU_PEAK'],
    weekly_metrics['RAM_AVG'], weekly_metrics['RAM_PEAK'],
    weekly_metrics['DISK_AVG'], weekly_metrics['DISK_PEAK'],
    network_gb
)}
"""

os.makedirs(REPORTS_DIR, exist_ok=True)
with open(report_filename, "w") as f:
    f.write(report_content)

print(f"Weekly report generated: {report_filename}")
