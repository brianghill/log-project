#!/usr/bin/env python3

import os
import json
import configparser
import psutil
import datetime
import smtplib
from email.message import EmailMessage

# ---------------- CONFIG ----------------

BASE_DIR = os.path.expanduser("~/log-project")
CONFIG_PATH = os.path.join(BASE_DIR, "config/config.conf")
STATE_FILE = os.path.join(BASE_DIR, "alerts_state.json")
HEALTH_LOG = os.path.join(BASE_DIR, "logs/health.log")

config = configparser.ConfigParser()
config.read(CONFIG_PATH)

CPU_THRESHOLD = float(config["DEFAULT"]["CPU_THRESHOLD"])
RAM_THRESHOLD = float(config["DEFAULT"]["RAM_THRESHOLD"])
DISK_THRESHOLD = float(config["DEFAULT"]["DISK_THRESHOLD"])
NETWORK_THRESHOLD = float(config["DEFAULT"]["NETWORK_THRESHOLD"])

EMAIL_ENABLED = config["DEFAULT"].get("EMAIL_ENABLED", "false").lower() == "true"
ALERT_EMAIL = config["DEFAULT"].get("ALERT_EMAIL", "")

# ---------------- STATE MANAGEMENT ----------------

def load_state():
    if not os.path.exists(STATE_FILE):
        return {"CPU": "NORMAL", "RAM": "NORMAL", "DISK": "NORMAL", "NETWORK": "NORMAL"}
    with open(STATE_FILE, "r") as f:
        return json.load(f)

def save_state(state):
    with open(STATE_FILE, "w") as f:
        json.dump(state, f)

# ---------------- EMAIL ----------------

def send_email(subject, body):
    if not EMAIL_ENABLED or not ALERT_EMAIL:
        return

    msg = EmailMessage()
    msg["From"] = ALERT_EMAIL
    msg["To"] = ALERT_EMAIL
    msg["Subject"] = subject
    msg.set_content(body)

    try:
        with smtplib.SMTP("localhost") as server:
            server.send_message(msg)
    except Exception as e:
        print(f"Email error: {e}")

# ---------------- METRIC COLLECTION ----------------

cpu_usage = psutil.cpu_percent(interval=1) * psutil.cpu_count()
ram_usage = psutil.virtual_memory().percent
disk_usage = psutil.disk_usage("/").percent
net_io = psutil.net_io_counters()
network_usage = net_io.bytes_sent + net_io.bytes_recv

timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")

# Log metrics
with open(HEALTH_LOG, "a") as f:
    f.write(
        f"{timestamp} | CPU_USAGE={cpu_usage}% | "
        f"RAM_USAGE={ram_usage}% | "
        f"DISK_USAGE={disk_usage}% | "
        f"NETWORK_USAGE={network_usage} bytes\n"
    )

# ---------------- ALERT CHECKING ----------------

state = load_state()

def check_metric(name, value, threshold):
    global state

    if value >= threshold:
        if state[name] != "ALERT":
            state[name] = "ALERT"
            send_email(
                f"ALERT: {name} threshold exceeded",
                f"{name} usage is {value} (threshold: {threshold})"
            )
            print(f"ALERT: {name} threshold exceeded ({value})")
    else:
        if state[name] == "ALERT":
            state[name] = "NORMAL"
            send_email(
                f"RESOLVED: {name} back to normal",
                f"{name} usage is now {value}"
            )
            print(f"RESOLVED: {name} back to normal ({value})")

check_metric("CPU", cpu_usage, CPU_THRESHOLD)
check_metric("RAM", ram_usage, RAM_THRESHOLD)
check_metric("DISK", disk_usage, DISK_THRESHOLD)
check_metric("NETWORK", network_usage, NETWORK_THRESHOLD)

save_state(state)
