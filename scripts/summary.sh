#!/bin/bash

BASE_DIR="/home/brianhill/monitoring-reports/raspberrypi5"
LATEST_LOG=$(ls -t $BASE_DIR/*monitor-*.log | head -n 1)

HOST=$(grep "Host:" "$LATEST_LOG" | awk '{print $2}')
DATE=$(date +"%Y-%m-%d-%H%M%S")

SUMMARY_LOG="$BASE_DIR/${HOST}-SUMMARY-$DATE.log"
SUMMARY_HTML="$BASE_DIR/${HOST}-SUMMARY-$DATE.html"
TREND_FILE="$BASE_DIR/${HOST}-trend.log"

CPU=$(grep "CPU Load:" "$LATEST_LOG" | awk '{print $3}')
DISK=$(grep "Disk Usage:" "$LATEST_LOG" | awk '{print $3}' | tr -d '%')
MEM=$(grep "Memory Usage:" "$LATEST_LOG" | awk '{print $3}' | tr -d '%')
SSH=$(grep "SSH Status:" "$LATEST_LOG" | awk '{print $3}')

TEMP_RAW=$(vcgencmd measure_temp 2>/dev/null | cut -d= -f2 | tr -d "'C")
TEMP=${TEMP_RAW:-0}

UPTIME=$(uptime -p)

risk_cpu() {
    if (( $(echo "$CPU > 3.5" | bc -l) )); then echo "CRITICAL"
    elif (( $(echo "$CPU > 2.0" | bc -l) )); then echo "HIGH"
    elif (( $(echo "$CPU > 1.0" | bc -l) )); then echo "MEDIUM"
    else echo "LOW"; fi
}

risk_percent() {
    if [ "$1" -gt 95 ]; then echo "CRITICAL"
    elif [ "$1" -gt 85 ]; then echo "HIGH"
    elif [ "$1" -gt 70 ]; then echo "MEDIUM"
    else echo "LOW"; fi
}

risk_temp() {
    if (( $(echo "$TEMP > 85" | bc -l) )); then echo "CRITICAL"
    elif (( $(echo "$TEMP > 75" | bc -l) )); then echo "HIGH"
    elif (( $(echo "$TEMP > 65" | bc -l) )); then echo "MEDIUM"
    else echo "LOW"; fi
}

CPU_RISK=$(risk_cpu)
DISK_RISK=$(risk_percent "$DISK")
MEM_RISK=$(risk_percent "$MEM")
TEMP_RISK=$(risk_temp)

if [ "$SSH" != "active" ]; then
    SSH_RISK="HIGH"
else
    SSH_RISK="LOW"
fi

CRITICAL=0
HIGH=0
MEDIUM=0

for R in $CPU_RISK $DISK_RISK $MEM_RISK $TEMP_RISK $SSH_RISK; do
    [ "$R" = "CRITICAL" ] && ((CRITICAL++))
    [ "$R" = "HIGH" ] && ((HIGH++))
    [ "$R" = "MEDIUM" ] && ((MEDIUM++))
done

if [ "$CRITICAL" -gt 0 ]; then
    OVERALL="CRITICAL"
elif [ "$HIGH" -ge 1 ]; then
    OVERALL="HIGH"
elif [ "$MEDIUM" -ge 1 ]; then
    OVERALL="MEDIUM"
else
    OVERALL="LOW"
fi

colorize() {
    case $1 in
        CRITICAL) echo "red" ;;
        HIGH) echo "orange" ;;
        MEDIUM) echo "gold" ;;
        LOW) echo "green" ;;
    esac
}

OVERALL_COLOR=$(colorize $OVERALL)

{
echo "System Health Summary"
echo "Host: $HOST"
echo "Date: $DATE"
echo "----------------------------------"
echo "CPU Load: $CPU ($CPU_RISK)"
echo "Disk Usage: $DISK% ($DISK_RISK)"
echo "Memory Usage: $MEM% ($MEM_RISK)"
echo "Temperature: ${TEMP}°C ($TEMP_RISK)"
echo "Uptime: $UPTIME"
echo "SSH Status: $SSH ($SSH_RISK)"
echo "----------------------------------"
echo "Overall Risk Level: $OVERALL"
} > "$SUMMARY_LOG"

cat > "$SUMMARY_HTML" <<EOF
<!DOCTYPE html>
<html>
<head>
<title>System Health Report</title>
<style>
body { font-family: Arial; }
.low { color: green; }
.medium { color: gold; }
.high { color: orange; }
.critical { color: red; font-weight: bold; }
</style>
</head>
<body>
<h1>System Health Report</h1>
<p><strong>Host:</strong> $HOST</p>
<p><strong>Date:</strong> $DATE</p>
<hr>
<p>CPU Load: $CPU (<span class="$(echo $CPU_RISK | tr '[:upper:]' '[:lower:]')">$CPU_RISK</span>)</p>
<p>Disk Usage: $DISK% (<span class="$(echo $DISK_RISK | tr '[:upper:]' '[:lower:]')">$DISK_RISK</span>)</p>
<p>Memory Usage: $MEM% (<span class="$(echo $MEM_RISK | tr '[:upper:]' '[:lower:]')">$MEM_RISK</span>)</p>
<p>Temperature: ${TEMP}°C (<span class="$(echo $TEMP_RISK | tr '[:upper:]' '[:lower:]')">$TEMP_RISK</span>)</p>
<p>Uptime: $UPTIME</p>
<p>SSH Status: $SSH (<span class="$(echo $SSH_RISK | tr '[:upper:]' '[:lower:]')">$SSH_RISK</span>)</p>
<hr>
<h2 class="$(echo $OVERALL | tr '[:upper:]' '[:lower:]')">
Overall Risk Level: $OVERALL
</h2>
</body>
</html>
EOF

echo "$DATE,$CPU,$DISK,$MEM,$TEMP,$OVERALL" >> "$TREND_FILE"
tail -n 14 "$TREND_FILE" > "$TREND_FILE.tmp" && mv "$TREND_FILE.tmp" "$TREND_FILE"

if [[ "$OVERALL" == "HIGH" || "$OVERALL" == "CRITICAL" ]]; then
    echo "Alert: $HOST risk level is $OVERALL at $DATE" | mail -s "Monitoring Alert - $HOST" your@email.com
fi

echo "Summary report saved to:"
echo "$SUMMARY_LOG"
echo "$SUMMARY_HTML"









