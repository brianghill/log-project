#!/bin/bash

# AnchorPoint Monitoring Runner
# Runs monitor.sh then summary.sh

PROJECT_DIR="$HOME/log-project"
SCRIPT_DIR="$PROJECT_DIR/scripts"

# Run monitoring collection
$SCRIPT_DIR/monitor.sh

# Wait 2 seconds to ensure log file finishes writing
sleep 2

HOSTNAME=$(hostname)

SRC="$HOME/monitoring-reports/$HOSTNAME"
DEST="$HOME/central-monitoring/$HOSTNAME"

mkdir -p "$DEST"

if [ -d "$SRC" ]; then
    cp "$SRC"/* "$DEST"/ 2>/dev/null
fi
