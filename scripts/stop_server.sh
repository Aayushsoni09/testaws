#!/bin/bash
APP_NAME="nextjsproject"

# Stop PM2
pm2 stop "$APP_NAME" || true
pm2 delete "$APP_NAME" || true

# Stop Nginx (if exists)
if systemctl list-unit-files | grep -q nginx.service; then
    sudo systemctl stop nginx
fi
