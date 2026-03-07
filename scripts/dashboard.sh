#!/bin/bash

REPORT_DIR="$HOME/monitoring-reports"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
RESET='\033[0m'

echo "========================================"
echo -e "${CYAN}ANCHORPOINT MONITORING DASHBOARD${RESET}"
echo "========================================"
echo ""

for HOST_DIR in $REPORT_DIR/*; do

    if [ -d "$HOST_DIR" ]; then

	    LATEST=$(ls -t "$HOST_DIR"/*Summary*.log 2>/dev/null | head -1)

        if [ -f "$LATEST" ]; then

            HOST=$(grep "Host:" "$LATEST" | awk -F': ' '{print $2}')
            CPU_LOAD=$(grep "CPU Load:" "$LATEST" | awk '{print $3}')
            CPU_USAGE=$(grep "CPU Usage:" "$LATEST" | awk '{print $3}')
            MEM=$(grep "Memory Usage:" "$LATEST" | awk '{print $3}')
            DISK=$(grep "Disk Usage:" "$LATEST" | awk '{print $3}')
            TEMP=$(grep "Temperature:" "$LATEST" | awk '{print $2}')
            RX=$(grep "Network RX:" "$LATEST" | awk '{print $3}')
            TX=$(grep "Network TX:" "$LATEST" | awk '{print $3}')
            SSH=$(grep "SSH Status:" "$LATEST" | awk '{print $3}')
            RISK=$(grep "Overall Risk Level:" "$LATEST" | awk '{print $4}')

            echo "----------------------------------------"
            echo -e "Host: ${CYAN}$HOST${RESET}"

            printf "CPU Load:      %s\n" "$CPU_LOAD"
            printf "CPU Usage:     %s\n" "$CPU_USAGE"
            printf "Memory Usage:  %s\n" "$MEM"
            printf "Disk Usage:    %s\n" "$DISK"
            printf "Temperature:   %s\n" "$TEMP"
            printf "Network RX:    %s MB\n" "$RX"
            printf "Network TX:    %s MB\n" "$TX"

            if [ "$SSH" = "active" ]; then
                echo -e "SSH Status:    ${GREEN}$SSH${RESET}"
            else
                echo -e "SSH Status:    ${RED}$SSH${RESET}"
            fi

            case $RISK in
                LOW)
                    echo -e "Risk Level:    ${GREEN}$RISK${RESET}"
                    ;;
                MEDIUM)
                    echo -e "Risk Level:    ${YELLOW}$RISK${RESET}"
                    ;;
                HIGH|CRITICAL)
                    echo -e "Risk Level:    ${RED}$RISK${RESET}"
                    ;;
                *)
                    echo "Risk Level:    $RISK"
                    ;;
            esac

        fi

    fi

done

echo ""
echo "========================================"
