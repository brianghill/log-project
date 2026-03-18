#!/bin/bash

OUTPUT="$HOME/central-monitoring/dashboard.html"

echo "<html><head><title>Monitoring Dashboard</title><meta http-equiv=\"refresh\" content=\"10\"></head><body>" > "$OUTPUT"
echo "<h1>AnchorPoint Monitoring</h1>" >> "$OUTPUT"

for HOST_DIR in "$HOME/central-monitoring"/*; do
    [ -d "$HOST_DIR" ] || continue

    HOST=$(basename "$HOST_DIR")
    LATEST=$(ls -t "$HOST_DIR"/*Summary*.log 2>/dev/null | head -n1)

    if [ -f "$LATEST" ]; then
        echo "<h2>$HOST</h2><pre>" >> "$OUTPUT"
        grep -E "CPU Usage|Disk Usage|Memory Usage|Overall Risk Level" "$LATEST" >> "$OUTPUT"
        echo "</pre>" >> "$OUTPUT"
    fi
done

echo "</body></html>" >> "$OUTPUT"
