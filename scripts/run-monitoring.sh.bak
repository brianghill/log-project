#!/bin/bash

# AnchorPoint Monitoring Runner
# Runs monitor.sh then summary.sh

PROJECT_DIR="/home/brianhill/log-project"
SCRIPT_DIR="$PROJECT_DIR/scripts"

# Run monitoring collection
$SCRIPT_DIR/monitor.sh

# Wait 2 seconds to ensure log file finishes writing
sleep 2

# Generate summary
$SCRIPT_DIR/summary.sh
