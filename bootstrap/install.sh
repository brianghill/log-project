#!/bin/bash

#############################################
# AnchorPoint Monitoring - Bootstrap Installer
#############################################

echo "🚀 Starting AnchorPoint install..."

# Step 1 - Ensure git exists
if ! command -v git &> /dev/null; then
    echo "📦 Installing git..."
    sudo apt update && sudo apt install -y git
fi

# Step 2 - Clone repo if not present
cd ~ || exit

if [ ! -d "log-project" ]; then
    echo "📥 Cloning monitoring system..."
    git clone https://github.com/brianghill/log-project.git
else
    echo "ℹ️ Repo already exists. Skipping clone."
fi

# Step 3 - Run main installer
cd log-project || exit

chmod +x scripts/install.sh
bash scripts/install.sh

echo "✅ AnchorPoint installation complete."
