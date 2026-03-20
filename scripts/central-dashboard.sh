#!/bin/bash

BASE_DIR="$HOME/central-monitoring"

echo "=========================================="
echo "   AnchorPoint Central Monitoring Dashboard"
echo "=========================================="
echo ""

for HOST_DIR in "$BASE_DIR"/*; do
    [ -d "$HOST_DIR" ] || continue

    HOST=$(basename "$HOST_DIR")
    LATEST=$(ls -t "$HOST_DIR"/*Summary*.log 2>/dev/null | head -n1)

    if [ -z "$LATEST" ]; then
        echo "------------------------------------------"
        echo "Host: $HOST"
        echo "No data available"
        echo ""
        continue
    fi

    LAST_MOD=$(stat -c %y "$LATEST" | cut -d'.' -f1)

    CPU=$(grep "CPU Usage" "$LATEST" | awk -F':' '{print $2}')
    DISK=$(grep "Disk Usage" "$LATEST" | awk -F':' '{print $2}')
    MEM=$(grep "Memory Usage" "$LATEST" | awk -F':' '{print $2}')
    RISK=$(grep "Overall Risk Level" "$LATEST" | awk -F':' '{print $2}')

    echo "------------------------------------------"
    echo "Host: $HOST"
    echo "Last Report: $LAST_MOD"
    echo "------------------------------------------"
    echo "CPU Usage:$CPU"
    echo "Disk Usage:$DISK"
    echo "Memory Usage:$MEM"
    echo "Overall Risk Level:$RISK"
    echo ""

done
