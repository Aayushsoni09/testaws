#!/bin/bash
set -e

echo "=== Starting dependencies installation ==="

# Create deployment directory if it doesn’t exist
if [ ! -d "/var/www/nextjsproject" ]; then
    sudo mkdir -p /var/www/nextjsproject
fi

# Change ownership to ec2-user
sudo chown -R ec2-user:ec2-user /var/www/nextjsproject || { echo "❌ Failed to change ownership"; exit 1; }

# Install Node.js 18 and npm via dnf (smaller footprint than NVM)
echo "=== Installing Node.js 18 ==="
sudo dnf install -y nodejs || { echo "❌ Failed to install Node.js"; exit 1; }

# Install Nginx
echo "=== Installing Nginx ==="
sudo dnf install -y nginx || { echo "❌ Nginx installation failed"; exit 1; }

# Install PM2 globally
echo "=== Installing PM2 ==="
npm install -g pm2 || { echo "❌ PM2 installation failed"; exit 1; }

# Configure Nginx
echo "=== Configuring Nginx ==="
sudo tee /etc/nginx/conf.d/nextjs_proxy.conf > /dev/null <<'EOF'
server {
    listen 80;
    server_name _;
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
EOF

# Start and enable Nginx
echo "=== Starting services ==="
sudo systemctl enable nginx || { echo "❌ Failed to enable Nginx"; exit 1; }
sudo systemctl start nginx || { echo "❌ Failed to start Nginx"; exit 1; }

# Verify installations
echo "=== Verifying Versions ==="
node -v || { echo "❌ Node.js not installed"; exit 1; }
npm -v || { echo "❌ npm not installed"; exit 1; }
nginx -v || { echo "❌ Nginx not installed"; exit 1; }
pm2 --version || { echo "❌ PM2 not installed"; exit 1; }

echo "✅ Dependencies installed successfully!"
