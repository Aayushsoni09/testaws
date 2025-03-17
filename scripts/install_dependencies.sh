#!/bin/bash

# Enable Amazon Linux Extras for Node.js
sudo amazon-linux-extras enable nodejs18
sudo yum install -y nodejs npm

# Verify Node.js installation
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Exiting..."
    exit 1
fi

if ! command -v npm &> /dev/null; then
    echo "❌ npm is not installed. Exiting..."
    exit 1
fi

# Install PM2 globally
sudo npm install -g pm2

# Install Nginx
sudo amazon-linux-extras enable nginx1
sudo yum install -y nginx

# Ensure Nginx configuration directory exists
sudo mkdir -p /etc/nginx/conf.d

# Create Nginx configuration for Next.js
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

# Start and enable Nginx
sudo systemctl start nginx
sudo systemctl enable nginx
