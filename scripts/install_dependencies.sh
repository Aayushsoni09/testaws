#!/bin/bash
set -e

echo "=== Starting dependencies installation ==="

# ========== System Dependencies FIRST ==========
# Install Node.js 18 and npm
echo "=== Installing Node.js 18 ==="
sudo dnf install -y nodejs || { echo "❌ Failed to install Node.js"; exit 1; }

# Install Nginx
echo "=== Installing Nginx ==="
sudo dnf install -y nginx || { echo "❌ Nginx installation failed"; exit 1; }

# Install PM2 globally
echo "=== Installing PM2 ==="
sudo npm install -g pm2 || { echo "❌ PM2 installation failed"; exit 1; }

# ========== App Dependencies SECOND ==========
# Navigate to app directory (files are now copied by CodeDeploy)
echo "=== Installing app dependencies ==="
cd /var/www/nextjsproject || { echo "❌ Failed to enter /var/www/nextjsproject"; exit 1; }
npm install --production || { echo "❌ npm install failed"; exit 1; }

# ========== Post-Install Setup ==========
# Fix ownership
sudo chown -R ec2-user:ec2-user /var/www/nextjsproject || { echo "❌ Failed to change ownership"; exit 1; }

# Configure Nginx logs
echo "=== Ensuring Nginx log directory exists ==="
sudo mkdir -p /var/log/nginx
sudo touch /var/log/nginx/error.log
sudo chown nginx:nginx /var/log/nginx/error.log
sudo chmod 640 /var/log/nginx/error.log

# Test Nginx config
echo "=== Testing Nginx config ==="
sudo nginx -t || { echo "❌ Nginx config test failed"; exit 1; }

# Start services
echo "=== Starting services ==="
sudo systemctl start nginx || { echo "❌ Failed to start Nginx"; exit 1; }
sudo systemctl enable nginx || { echo "❌ Failed to enable Nginx"; exit 1; }

# Verify installations
echo "=== Verifying Versions ==="
node -v || { echo "❌ Node.js not installed"; exit 1; }
npm -v || { echo "❌ npm not installed"; exit 1; }
nginx -v || { echo "❌ Nginx not installed"; exit 1; }
pm2 --version || { echo "❌ PM2 not installed"; exit 1; }

echo "✅ Dependencies installed successfully!"
