#!/bin/bash

BASE_DIR="$HOME/central-monitoring"

echo "==== ⚠️ ACTIVE ALERTS ===="

for HOST_DIR in "$BASE_DIR"/*; do
    [ -d "$HOST_DIR" ] || continue

    HOST=$(basename "$HOST_DIR")
    LATEST=$(ls -t "$HOST_DIR"/*Summary*.log 2>/dev/null | head -n1)

    if grep -q "HIGH" "$LATEST"; then
        echo "🚨 $HOST has HIGH risk"
    fi
done
