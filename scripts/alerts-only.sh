#!/bin/bash
# =========================================
# alerts-only.sh
# Collect system metrics and log alerts
# =========================================

ALERT_LOG="$HOME/log-project/logs/alerts.log"

DISK_CRIT=${DISK_CRIT_OVERRIDE:-80}
MEM_CRIT=${MEM_CRIT_OVERRIDE:-80}
LOAD_CRIT=${LOAD_CRIT_OVERRIDE:-5}
NETWORK_CRIT=${NETWORK_CRIT_OVERRIDE:-100000}  # bytes/sec

DISK_WARN=$((DISK_CRIT - 10))
MEM_WARN=$((MEM_CRIT - 10))
LOAD_WARN=$(echo "$LOAD_CRIT * 0.8" | bc)

echo "==== ALERT CHECK $(date -u) ====" >> "$ALERT_LOG"

#############################################
# DISK USAGE
#############################################
DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | tr -d '%')
if [[ "$DISK_USAGE" =~ ^[0-9]+$ ]]; then
    if [ "$DISK_USAGE" -ge "$DISK_CRIT" ]; then
        echo "🚨 CRITICAL DISK: $DISK_USAGE%" >> "$ALERT_LOG"
    elif [ "$DISK_USAGE" -ge "$DISK_WARN" ]; then
        echo "⚠️ WARNING DISK: $DISK_USAGE%" >> "$ALERT_LOG"
    fi
fi

#############################################
# MEMORY USAGE
#############################################
MEM_USAGE=$(free | awk '/Mem:/ {printf("%.0f", $3/$2*100)}')
if [[ "$MEM_USAGE" =~ ^[0-9]+$ ]]; then
    if [ "$MEM_USAGE" -ge "$MEM_CRIT" ]; then
        echo "🚨 CRITICAL MEMORY: $MEM_USAGE%" >> "$ALERT_LOG"
    elif [ "$MEM_USAGE" -ge "$MEM_WARN" ]; then
        echo "⚠️ WARNING MEMORY: $MEM_USAGE%" >> "$ALERT_LOG"
    fi
fi

#############################################
# CPU LOAD
#############################################
CPU_LOAD=$(uptime | awk -F'load average:' '{print $2}' | cut -d',' -f1 | xargs)
CPU_LOAD_INT=$(printf "%.0f" "$CPU_LOAD")
if [[ "$CPU_LOAD_INT" =~ ^[0-9]+$ ]]; then
    if [ "$CPU_LOAD_INT" -ge "$(printf "%.0f" "$LOAD_CRIT")" ]; then
        echo "🚨 CRITICAL CPU LOAD: $CPU_LOAD" >> "$ALERT_LOG"
    elif [ "$CPU_LOAD_INT" -ge "$(printf "%.0f" "$LOAD_WARN")" ]; then
        echo "⚠️ WARNING CPU LOAD: $CPU_LOAD" >> "$ALERT_LOG"
    fi
fi

#############################################
# NETWORK USAGE (RX bytes over 1 sec)
#############################################
NET_INTERFACE="eth0"
RX1=$(cat /sys/class/net/$NET_INTERFACE/statistics/rx_bytes 2>/dev/null)
sleep 1
RX2=$(cat /sys/class/net/$NET_INTERFACE/statistics/rx_bytes 2>/dev/null)
if [[ -n "$RX1" && -n "$RX2" ]]; then
    RX_RATE=$((RX2 - RX1))
    if [ "$RX_RATE" -ge "${NETWORK_CRIT_OVERRIDE:-$NETWORK_CRIT}" ]; then
        echo "🚨 CRITICAL NETWORK RX: $RX_RATE bytes/sec" >> "$ALERT_LOG"
    fi
fi

echo "" >> "$ALERT_LOG"
echo "✅ Alert check complete. Log: $ALERT_LOG"
