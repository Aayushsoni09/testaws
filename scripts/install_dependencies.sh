#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

echo "=== Starting dependencies installation ==="

# Create deployment directory
sudo mkdir -p /var/www/nextjsproject
sudo chown -R ec2-user:ec2-user /var/www/nextjsproject

# Install Node.js 14 from NodeSource repository (compatible with Amazon Linux 2)
echo "=== Installing Node.js 14 ==="
curl -sL https://rpm.nodesource.com/setup_14.x | sudo bash -
sudo yum install -y nodejs

# Install Nginx
echo "=== Installing Nginx ==="
sudo amazon-linux-extras install -y nginx1

# Install PM2
echo "=== Installing PM2 ==="
sudo npm install -g pm2

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

# Enable and start services
echo "=== Starting services ==="
sudo systemctl enable nginx
sudo systemctl start nginx

# Verify installations
echo "=== Verifying Versions ==="
node -v || { echo "❌ Node.js installation failed!"; exit 1; }
npm -v || { echo "❌ npm installation failed!"; exit 1; }
nginx -v || { echo "❌ Nginx installation failed!"; exit 1; }
pm2 --version || { echo "❌ PM2 installation failed!"; exit 1; }

echo "✅ Dependencies installed successfully!"
