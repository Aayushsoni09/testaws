#!/bin/bash

# Update system packages
sudo yum update -y

# Install Node.js from Amazon Linux Extras
sudo amazon-linux-extras enable nodejs18
sudo yum install -y nodejs npm

# Verify Node.js and npm installation
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Exiting..."
    exit 1
fi
if ! command -v npm &> /dev/null; then
    echo "❌ npm is not installed. Exiting..."
    exit 1
fi

# Ensure the application directory exists
sudo mkdir -p /var/www/nextjsproject
sudo chown ec2-user:ec2-user /var/www/nextjsproject
cd /var/www/nextjsproject

# Install dependencies
su - ec2-user -c "npm install"

# Install PM2 for process management
su - ec2-user -c "npm install -g pm2"

# Install Nginx using Amazon Linux Extras
sudo amazon-linux-extras enable nginx1
sudo yum install -y nginx

# Ensure Nginx config directory exists
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

# Start & enable Nginx
sudo systemctl start nginx
sudo systemctl enable nginx
