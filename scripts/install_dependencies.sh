#!/bin/bash

# Update system and install necessary packages
sudo yum update -y
sudo yum install -y nginx

# Install Node.js and npm
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo yum install -y nodejs

# Install PM2 globally
sudo npm install -g pm2

# Navigate to project directory (assuming it's /var/www/nextjsproject)
cd /var/www/nextjsproject

# Install project dependencies
npm install

# Build and start Next.js application
npm run build
pm start &

# Configure NGINX as a reverse proxy for Next.js
sudo cat << EOF > /etc/nginx/conf.d/nextjs_proxy.conf
server {
    listen 80;
    server_name app.nextjsproject.com;

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

# Restart NGINX to apply changes
sudo systemctl enable nginx
sudo systemctl restart nginx
