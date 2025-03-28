#!/bin/bash
set -e  # Exit on any error

echo "=== Starting server ==="

# Load NVM and set up Node.js environment for ec2-user
export NVM_DIR="/home/ec2-user/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" || { echo "❌ NVM not found at $NVM_DIR"; exit 1; }

# Ensure the correct Node.js version is used
nvm use 14 || { echo "❌ Failed to use Node.js 14"; exit 1; }

# Check and restart Nginx if needed
echo "=== Checking Nginx ==="
if ! systemctl is-active --quiet nginx; then
    sudo systemctl start nginx || { echo "❌ Failed to start Nginx"; exit 1; }
fi
sudo systemctl enable nginx || { echo "❌ Failed to enable Nginx"; exit 1; }

# Start Next.js app using PM2
echo "=== Starting Next.js app with PM2 ==="
cd /var/www/nextjsproject || { echo "❌ Directory /var/www/nextjsproject not found"; exit 1; }
npm install || { echo "❌ npm install failed"; exit 1; }
npm run build || { echo "❌ npm run build failed"; exit 1; }
pm2 start npm --name "nextjsproject" -- start || { echo "❌ PM2 failed to start app"; exit 1; }
pm2 save || { echo "❌ PM2 save failed"; exit 1; }

# Set up PM2 to run on system boot as ec2-user
echo "=== Setting up PM2 startup ==="
pm2 startup systemd -u ec2-user || { echo "❌ PM2 startup setup failed"; exit 1; }
sudo systemctl enable pm2-ec2-user || { echo "❌ Failed to enable PM2 service"; exit 1; }

echo "✅ Server started successfully!"
