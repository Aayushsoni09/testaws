#!/bin/bash
set -e

echo "=== Starting dependencies installation ==="

# Create deployment directory if it doesn’t exist
if [ ! -d "/var/www/nextjsproject" ]; then
    sudo mkdir -p /var/www/nextjsproject
fi
echo "=== Installing dependencies ==="
cd /var/www/nextjsproject
npm install --production
# Change ownership to ec2-user
sudo chown -R ec2-user:ec2-user /var/www/nextjsproject || { echo "❌ Failed to change ownership"; exit 1; }
echo "✅ Dependencies installed!"
# Install Node.js 18 and npm via dnf (smaller footprint than NVM)
echo "=== Installing Node.js 18 ==="
sudo dnf install -y nodejs || { echo "❌ Failed to install Node.js"; exit 1; }

# Install Nginx
echo "=== Installing Nginx ==="
sudo dnf install -y nginx || { echo "❌ Nginx installation failed"; exit 1; }

# Install PM2 globally
echo "=== Installing PM2 ==="
sudo npm install -g pm2 || { echo "❌ PM2 installation failed"; exit 1; }

# Ensure Nginx log directory and files exist
echo "=== Ensuring Nginx log directory and files exist ==="
sudo mkdir -p /var/log/nginx
sudo touch /var/log/nginx/error.log
sudo chown nginx:nginx /var/log/nginx/error.log
sudo chmod 640 /var/log/nginx/error.log

# Configure Nginx
echo "=== Configuring Nginx ==="
sudo tee /etc/nginx/conf.d/nextjs_proxy.conf > /dev/null <<'EOF'
server {
    listen 80;
    server_name _;
    location / {
        return 200 'Nginx is installed and running.';
        add_header Content-Type text/plain;
    }
}
EOF
echo "=== Testing Nginx config ==="
sudo nginx -t || { echo "❌ Nginx config test failed"; exit 1; }
# Start and enable Nginx
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
