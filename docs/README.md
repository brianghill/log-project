Log Monitoring & Alert System
==============================

This project is a lightweight log monitoring system built in Python and Bash.

It analyzes application log files, counts error levels, and generates alerts
when error thresholds are exceeded.

Components
----------
scripts/log_analyzer.py
    Main Python script that scans logs and counts INFO, WARNING, and ERROR entries.

scripts/run_log_check.sh
    Wrapper script that runs the analyzer and manages daily alert logging.

config.conf
    Configuration file containing:
    - Log file path
    - Error threshold
    - Report output locations
    - CPU, RAM, Disk, and Network thresholds

logs/
    Contains the application logs being analyzed.

reports/
    Output directory containing:
    - alerts.log  → Records when error thresholds are exceeded
    - history.log → Historical counts of log activity
    - health.log  → System health check output
    - dashboard.txt → Current CPU, RAM, Disk, and Network stats

System Metrics
--------------
- CPU usage %
- RAM usage %
- Disk usage %
- Network activity (bytes sent/received)

Purpose
-------
This system simulates real-world log monitoring used by IT support teams
and small businesses to detect recurring application problems.

Running the Monitor
------------------
Run manually:
    bash scripts/run_log_check.sh

Stop alerts:
    Comment out or disable the cron job / script execution.

Author: Brian Hill
