#!/bin/bash
# Stop Next.js application via PM2 and Nginx
pm2 stop next-app || true
pm2 delete next-app || true

# Stop Nginx (if running)
if systemctl is-active --quiet nginx; then
    sudo systemctl stop nginx
fi

# Optional: Kill any remaining Node processes
pkill -f "node.*next" || true
