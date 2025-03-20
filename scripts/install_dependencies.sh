#!/bin/bash
# For Amazon Linux 2023
sudo dnf install -y nginx
sudo systemctl enable nginx
sudo systemctl start nginx

# Verify installation
if ! command -v nginx &> /dev/null; then
    echo "❌ Nginx installation failed!"
    exit 1
fi
# Enable and install Node.js 18
sudo amazon-linux-extras enable nodejs18
sudo yum clean metadata
sudo yum install -y nodejs npm

# Verify Node.js installation
node -v || exit 1
npm -v || exit 1
nginx -v || exit 1
# Install PM2
sudo npm install -g pm2

# Install Nginx
sudo amazon-linux-extras enable nginx1
sudo yum install -y nginx

# Create Nginx config
sudo mkdir -p /etc/nginx/conf.d
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

# Start Nginx
sudo systemctl start nginx
sudo systemctl enable nginx
