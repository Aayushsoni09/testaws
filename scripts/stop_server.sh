#!/bin/bash
set -e  # Exit on any error

echo "=== Stopping server ==="

# Load NVM and set up Node.js environment for ec2-user
export NVM_DIR="/home/ec2-user/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" || { echo "❌ NVM not found at $NVM_DIR"; exit 1; }

# Ensure the correct Node.js version is used
nvm use 18 || { echo "❌ Failed to use Node.js 18"; exit 1; }

APP_NAME="nextjsproject"

# Stop PM2
echo "=== Stopping PM2 ==="
pm2 stop "$APP_NAME" || true  # Ignore errors if already stopped
pm2 delete "$APP_NAME" || true  # Ignore errors if already deleted

# Stop Nginx (if running)
echo "=== Stopping Nginx ==="
if systemctl is-active --quiet nginx; then
    sudo systemctl stop nginx || { echo "❌ Failed to stop Nginx"; exit 1; }
fi

echo "✅ Server stopped successfully!"
