#!/bin/bash

REPORT_DIR="/Users/brian/monitoring-reports"

echo "========================================"
echo "MONITORING DASHBOARD"
echo "========================================"
echo ""

for HOST in $REPORT_DIR/*; do
    if [ -d "$HOST" ]; then
        SUMMARY="$HOST/summary.txt"
        if [ -f "$SUMMARY" ]; then
            echo "----------------------------------------"
            grep "Hostname:" $SUMMARY
            grep "Disk Usage:" $SUMMARY
            grep "Memory Usage:" $SUMMARY
            grep "Failed Services:" $SUMMARY
            grep "Failed SSH Attempts:" $SUMMARY
        fi
    fi
done

echo ""
echo "========================================"
