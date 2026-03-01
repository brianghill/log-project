#!/bin/bash

echo "Simulating CRITICAL disk usage..."

# Fake a temporary high disk value
BASE_DIR="/home/brianhill/monitoring-reports/raspberrypi5"
LATEST_LOG=$(ls -t $BASE_DIR/*monitor-*.log | head -n 1)

cp "$LATEST_LOG" "$LATEST_LOG.bak"

sed -i 's/Disk Usage: [0-9]*/Disk Usage: 99/' "$LATEST_LOG"

echo "Modified log to force CRITICAL disk."

echo "Now running summary..."
./summary.sh

echo "Restoring original log..."
mv "$LATEST_LOG.bak" "$LATEST_LOG"

echo "Stress test complete."
