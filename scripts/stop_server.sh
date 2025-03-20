#!/bin/bash
set -e  # Exit on any error

echo "=== Stopping server ==="

# Load NVM and set up Node.js environment
export NVM_DIR="/root/.nvm"  # Matches runas: root
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" || { echo "❌ NVM not found at $NVM_DIR"; exit 1; }

# Ensure the correct Node.js version is used
nvm use 14 || { echo "❌ Failed to use Node.js 14"; exit 1; }

APP_NAME="nextjsproject"

# Stop PM2
echo "=== Stopping PM2 ==="
pm2 stop "$APP_NAME" || true  # Ignore errors if already stopped
pm2 delete "$APP_NAME" || true  # Ignore errors if already deleted

# Stop Nginx (if exists)
echo "=== Stopping Nginx ==="
if systemctl list-unit-files | grep -q nginx.service; then
    sudo systemctl stop nginx || { echo "❌ Failed to stop Nginx"; exit 1; }
fi

echo "✅ Server stopped successfully!"
