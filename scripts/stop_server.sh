#!/bin/bash
set -e  # Exit on any error

echo "=== Stopping server ==="

APP_NAME="nextjsproject"

# Stop PM2 Process
echo "=== Stopping PM2 Process ==="
pm2 stop "$APP_NAME" || true       # Gracefully stop the app
pm2 delete "$APP_NAME" || true     # Remove from PM2 list
pm2 flush || true                  # Clear logs to release file handles

# Kill Any Lingering Node.js Processes
echo "=== Terminating Node.js Processes ==="
pkill -f "next start" || true      # Force-kill Next.js processes
pkill -f "node /var/www/nextjsproject" || true  # Safety net

# Stop Nginx (Ignore errors if already stopped)
echo "=== Stopping Nginx ==="
sudo systemctl stop nginx || true  # Do not fail if Nginx isn't running

# Cleanup PM2 Daemon (Optional)
# pm2 kill || true  # Uncomment if PM2 itself hangs

echo "✅ Server stopped successfully!"
