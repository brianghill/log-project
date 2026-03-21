#!/bin/bash

# AnchorPoint Monitoring Runner
# Runs monitor.sh then summary.sh

PROJECT_DIR="$HOME/log-project"
SCRIPT_DIR="$PROJECT_DIR/scripts"

# Run monitoring
$SCRIPT_DIR/monitor.sh

sleep 2

# ✅ PUT THIS BACK
$SCRIPT_DIR/summary.sh

HOSTNAME=$(hostname)

SRC="$HOME/monitoring-reports/$HOSTNAME"
DEST="$HOME/central-monitoring/$HOSTNAME"

mkdir -p "$DEST"

if [ -d "$SRC" ]; then
    cp "$SRC"/* "$DEST"/ 2>/dev/null
fi
