#!/bin/bash
set -e  # Exit script on first error

echo "🚀 Removing any existing Node.js installations..."
sudo yum remove -y nodejs npm || true  # Ignore errors if they don't exist
sudo rm -rf /usr/local/lib/node_modules || true

echo "🚀 Cleaning yum cache..."
sudo yum clean all

echo "🚀 Ensuring Amazon Linux Extras is installed..."
sudo yum install -y amazon-linux-extras
sudo amazon-linux-extras enable nodejs18

echo "🚀 Installing Node.js and npm from Amazon Linux Extras..."
sudo yum install -y nodejs npm

# Verify installation
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is still not installed! Exiting..."
    exit 1
fi

if ! command -v npm &> /dev/null; then
    echo "❌ npm is still not installed! Exiting..."
    exit 1
fi

echo "✅ Node.js and npm installed successfully!"
node -v
npm -v

echo "🚀 Installing PM2 globally..."
sudo npm install -g pm2

echo "🚀 Installing and configuring Nginx..."
sudo amazon-linux-extras enable nginx1
sudo yum install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Ensure Nginx configuration directory exists
sudo mkdir -p /etc/nginx/conf.d

# Create Nginx config for Next.js
cat <<EOF | sudo tee /etc/nginx/conf.d/nextjs_proxy.conf
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

echo "🚀 Restarting Nginx..."
sudo systemctl restart nginx

echo "✅ All dependencies installed successfully!"
