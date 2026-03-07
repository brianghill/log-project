#!/bin/bash

echo "Starting CPU stress test..."

yes > /dev/null &
yes > /dev/null &
yes > /dev/null &
yes > /dev/null &

echo "4 CPU stress processes started."

sleep 20

echo "Stopping stress test..."

killall yes

echo "CPU stress test complete."
