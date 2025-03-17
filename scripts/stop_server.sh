#!/bin/bash
echo "=== Stopping Application ==="

# Stop PM2 process
pm2 stop nextjsproject || echo "PM2 process not found"
pm2 delete nextjsproject || echo "PM2 process not found"

# Stop Nginx
sudo systemctl stop nginx || echo "Nginx not running"

echo "=== Cleanup Complete ==="
