#!/bin/bash

# AnchorPoint Monitoring Runner

PROJECT_DIR="$HOME/log-project"
SCRIPT_DIR="$PROJECT_DIR/scripts"

# Run monitoring
$SCRIPT_DIR/monitor.sh

sleep 2

# Run summary
$SCRIPT_DIR/summary.sh

HOSTNAME=$(hostname)

SRC="$HOME/monitoring-reports/$HOSTNAME"
DEST="$HOME/central-monitoring/$HOSTNAME"

mkdir -p "$DEST"

# Local copy (always works)
if [ -d "$SRC" ]; then
    cp "$SRC"/* "$DEST"/ 2>/dev/null
fi

# 🔥 REMOTE COPY (FIXED SCP)
REMOTE_USER="brianhill"
REMOTE_HOST="100.125.19.28"
REMOTE_DIR="home/brianhill/central-monitoring/$HOSTNAME"

ssh ${REMOTE_USER}@${REMOTE_HOST} "mkdir -p ${REMOTE_DIR}"

scp "$SRC"/* ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/ 2>/dev/null
