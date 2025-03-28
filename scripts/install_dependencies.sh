#!/bin/bash
set -e

echo "=== Starting dependencies installation ==="

# Create deployment directory
mkdir -p /var/www/nextjsproject
chown -R ec2-user:ec2-user /var/www/nextjsproject

# Install NVM as ec2-user
echo "=== Installing NVM ==="
export NVM_DIR="/home/ec2-user/.nvm"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# Source NVM
echo "=== Sourcing NVM ==="
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Install Node.js 14
echo "=== Installing Node.js 14 ==="
nvm install 14
nvm use 14
nvm alias default 14

# Install Nginx (requires sudo)
echo "=== Installing Nginx ==="
sudo amazon-linux-extras install -y nginx1

# Install PM2 globally
echo "=== Installing PM2 ==="
npm install -g pm2

# Configure Nginx (requires sudo)
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

# Enable and start services (requires sudo)
echo "=== Starting services ==="
sudo systemctl enable nginx
sudo systemctl start nginx

# Verify installations
echo "=== Verifying Versions ==="
node -v
npm -v
nginx -v
pm2 --version

echo "✅ Dependencies installed successfully!"
