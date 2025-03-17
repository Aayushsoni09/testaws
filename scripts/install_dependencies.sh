#!/bin/bash
set -e  # Exit if any command fails

echo "🚀 Cleaning yum cache..."
sudo yum clean all

echo "🚀 Removing any old Node.js versions..."
sudo yum remove -y nodejs npm || true  # Ignore errors if they don’t exist

echo "🚀 Installing Node.js 18 from NodeSource..."
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo yum install -y nodejs

echo "🚀 Verifying installation..."
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is NOT installed! Exiting..."
    exit 1
fi

if ! command -v npm &> /dev/null; then
    echo "❌ npm is NOT installed! Exiting..."
    exit 1
fi

echo "✅ Node.js version: $(node -v)"
echo "✅ npm version: $(npm -v)"

echo "🚀 Installing PM2 globally..."
sudo npm install -g pm2

echo "🚀 Installing Nginx..."
sudo yum install -y nginx

echo "🚀 Starting and enabling Nginx..."
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
