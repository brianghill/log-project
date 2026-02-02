#!/usr/bin/env python3

import os
import shutil
import smtplib
import subprocess
from datetime import datetime
from email.message import EmailMessage
import configparser

CONFIG_PATH = os.path.expanduser("~/log-project/config.conf")

config = configparser.ConfigParser()
config.read(CONFIG_PATH)
cfg = config["DEFAULT"]

timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")


# ---------------- LOG ERROR COUNT ----------------
def count_errors(log_files):
    count = 0
    for file in log_files:
        path = os.path.expanduser(file.strip())
        if os.path.exists(path):
            with open(path) as f:
                for line in f:
                    if "ERROR" in line:
                        count += 1
    return count


# ---------------- CPU USAGE ----------------
def check_cpu_usage():
    try:
        output = subprocess.check_output(["ps", "-A", "-o", "%cpu"], text=True)
        lines = output.strip().split("\n")[1:]
        total_cpu = sum(float(x.strip()) for x in lines if x.strip())
        return round(total_cpu, 1)
    except Exception as e:
        print(f"Failed to check CPU usage: {e}")
        return None


# ---------------- DISK USAGE ----------------
def check_disk_usage():
    try:
        total, used, free = shutil.disk_usage("/")
        percent_used = round((used / total) * 100, 1)
        return percent_used
    except Exception as e:
        print(f"Failed to check disk usage: {e}")
        return None


# ---------------- RAM USAGE (FIXED) ----------------
def check_ram_usage():
    try:
        vm = subprocess.check_output(["vm_stat"], text=True)
        lines = vm.split("\n")

        # Get page size from header line like:
        # "Mach Virtual Memory Statistics: (page size of 16384 bytes)"
        page_size = 4096  # fallback default
        for line in lines:
            if "page size of" in line:
                page_size = int(line.split("page size of")[1].split("bytes")[0].strip())
                break

        pages = {}
        for line in lines:
            if ":" in line and "page size" not in line:
                key, val = line.split(":")
                val = val.strip().replace(".", "")
                if val.isdigit():
                    pages[key.strip()] = int(val)

        free = pages.get("Pages free", 0) * page_size
        active = pages.get("Pages active", 0) * page_size
        inactive = pages.get("Pages inactive", 0) * page_size
        wired = pages.get("Pages wired down", 0) * page_size

        used = active + inactive + wired
        total = used + free

        percent = round((used / total) * 100, 1)
        return percent

    except Exception as e:
        print(f"Failed to check RAM usage: {e}")
        return None


# ---------------- NETWORK USAGE ----------------
def check_network_usage():
    try:
        net = subprocess.check_output(["netstat", "-ib"], text=True)
        lines = net.split("\n")
        total_bytes = 0
        for line in lines[1:]:
            parts = line.split()
            if len(parts) > 9 and parts[0] == "en0":
                ibytes = int(parts[6])
                obytes = int(parts[9])
                total_bytes += ibytes + obytes
        return total_bytes
    except Exception as e:
        print(f"Failed to check network usage: {e}")
        return None


# ---------------- EMAIL ALERT ----------------
def send_email(subject):
    try:
        msg = EmailMessage()
        msg.set_content(subject)
        msg["Subject"] = "🚨 System Alert"
        msg["From"] = cfg["SMTP_USER"]
        msg["To"] = cfg["ALERT_EMAIL"]

        with smtplib.SMTP(cfg["SMTP_SERVER"], int(cfg["SMTP_PORT"])) as server:
            server.starttls()
            server.login(cfg["SMTP_USER"], cfg["SMTP_PASS"])
            server.send_message(msg)

        print("Alert email sent.")
    except Exception as e:
        print(f"Failed to send email: {e}")


# ---------------- MAIN ----------------
def main():
    log_files = cfg["LOG_FILES"].split(",")
    error_threshold = int(cfg["ERROR_THRESHOLD"])
    cpu_threshold = int(cfg.get("CPU_THRESHOLD", 80))
    disk_threshold = int(cfg.get("DISK_THRESHOLD", 90))
    ram_threshold = int(cfg.get("RAM_THRESHOLD", 85))
    net_threshold = int(cfg.get("NETWORK_THRESHOLD", 1000000000))

    alerts_path = os.path.expanduser("~/log-project/" + cfg["ALERT_LOG"])
    history_path = os.path.expanduser("~/log-project/" + cfg["HISTORY_LOG"])
    health_path = os.path.expanduser("~/log-project/" + cfg["HEALTH_LOG"])

    total_errors = count_errors(log_files)

    with open(history_path, "a") as history_log:
        history_log.write(f"{timestamp} | TOTAL_ERRORS={total_errors}\n")

    with open(health_path, "a") as health_log:

        cpu_usage = check_cpu_usage()
        if cpu_usage is not None:
            print(f"CPU Usage: {cpu_usage}%")
            health_log.write(f"{timestamp} | CPU_USAGE={cpu_usage}%\n")
            if cpu_usage > cpu_threshold:
                alert = f"⚠️ CPU USAGE HIGH ({cpu_usage}%)"
                print(f"ALERT: {alert}")
                send_email(alert)

        disk_usage = check_disk_usage()
        if disk_usage is not None:
            print(f"Disk Usage: {disk_usage}%")
            health_log.write(f"{timestamp} | DISK_USAGE={disk_usage}%\n")
            if disk_usage > disk_threshold:
                alert = f"⚠️ DISK USAGE HIGH ({disk_usage}%)"
                print(f"ALERT: {alert}")
                send_email(alert)

        ram_usage = check_ram_usage()
        if ram_usage is not None:
            print(f"RAM Usage: {ram_usage}%")
            health_log.write(f"{timestamp} | RAM_USAGE={ram_usage}%\n")
            if ram_usage > ram_threshold:
                alert = f"⚠️ RAM USAGE HIGH ({ram_usage}%)"
                print(f"ALERT: {alert}")
                send_email(alert)

        net_usage = check_network_usage()
        if net_usage is not None:
            health_log.write(f"{timestamp} | NETWORK_USAGE={net_usage} bytes\n")
            if net_usage > net_threshold:
                alert = f"⚠️ NETWORK USAGE HIGH ({net_usage} bytes)"
                print(f"ALERT: {alert}")
                send_email(alert)

    if total_errors > error_threshold:
        alert_line = f"{timestamp}: 🚨 ERROR THRESHOLD EXCEEDED (count={total_errors})\n"
        print(f"ALERT: 🚨 ERROR THRESHOLD EXCEEDED (count={total_errors})")
        with open(alerts_path, "a") as alert_log:
            alert_log.write(alert_line)
        send_email(alert_line)


if __name__ == "__main__":
    main()
