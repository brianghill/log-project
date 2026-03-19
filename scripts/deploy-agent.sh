#!/bin/bash

PROJECT_DIR="$HOME/log-project"
LOG_FILE="$PROJECT_DIR/logs/deploy.log"

echo "==============================" >> $LOG_FILE
echo "Deploy run: $(date)" >> $LOG_FILE

cd $PROJECT_DIR || exit

# Self-heal
git reset --hard >> $LOG_FILE 2>&1

# Update
git pull origin main >> $LOG_FILE 2>&1

# 🔥 RUN YOUR ACTUAL PIPELINE
bash scripts/run-monitoring.sh >> $LOG_FILE 2>&1

echo "Deploy complete" >> $LOG_FILE
