#!/bin/bash

# Update system packages
sudo yum update -y

# Install Node.js
sudo amazon-linux-extras enable nodejs18
sudo yum install -y nodejs npm

# Verify installation
node -v
npm -v

# Ensure the application directory exists
sudo mkdir -p /var/www/nextjsproject
sudo chown ec2-user:ec2-user /var/www/nextjsproject
cd /var/www/nextjsproject

# Install dependencies
su - ec2-user -c "npm install"

# Install PM2
su - ec2-user -c "npm install -g pm2"

# Install and start Nginx
sudo yum install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Create Nginx config for Next.js (if missing)
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

# Restart Nginx
sudo systemctl restart nginx
