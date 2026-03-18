#!/bin/bash

BASE_DIR="$HOME/central-monitoring"

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo "=========================================="
echo "   AnchorPoint Central Monitoring Dashboard"
echo "=========================================="
echo ""

for HOST_DIR in "$BASE_DIR"/*; do
    [ -d "$HOST_DIR" ] || continue

    HOST=$(basename "$HOST_DIR")
    LATEST_SUMMARY=$(ls -t "$HOST_DIR"/*Summary*.log 2>/dev/null | head -n1)

    if [ -f "$LATEST_SUMMARY" ]; then
        echo "------------------------------------------"
        echo "Host: $HOST"

        LAST_UPDATED=$(stat -c %y "$LATEST_SUMMARY" 2>/dev/null | cut -d'.' -f1)
        echo "Last Report: $LAST_UPDATED"
        echo "------------------------------------------"

        CPU=$(grep "CPU Usage" "$LATEST_SUMMARY")
        DISK=$(grep "Disk Usage" "$LATEST_SUMMARY")
        MEM=$(grep "Memory Usage" "$LATEST_SUMMARY")
        RISK=$(grep "Overall Risk Level" "$LATEST_SUMMARY")

        # Color logic
        if echo "$RISK" | grep -q "HIGH"; then
            COLOR=$RED
        elif echo "$RISK" | grep -q "MEDIUM"; then
            COLOR=$YELLOW
        else
            COLOR=$GREEN
        fi

        echo -e "$CPU"
        echo -e "$DISK"
        echo -e "$MEM"
        echo -e "${COLOR}$RISK${NC}"

        echo ""
    else
        echo "Host: $HOST"
        echo "No reports found."
        echo ""
    fi
done
