#!/bin/bash
set -e  # Exit on any error

echo "=== Stopping server ==="

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
