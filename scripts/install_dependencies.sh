#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

echo "=== Starting dependencies installation ==="

# Create deployment directory
sudo mkdir -p /var/www/nextjsproject
sudo chown -R ec2-user:ec2-user /var/www/nextjsproject

# Debug - check which package managers are available
echo "=== Checking package managers ==="
which yum || echo "yum not found"
which dnf || echo "dnf not found"

# Install Node.js using NVM (Node Version Manager)
echo "=== Installing NVM and Node.js ==="
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # Load nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # Load bash_completion
nvm install 18
nvm use 18

# Make Node.js available for sudo commands
sudo ln -sf $(which node) /usr/bin/node
sudo ln -sf $(which npm) /usr/bin/npm

# Install Nginx
echo "=== Installing Nginx ==="
sudo amazon-linux-extras install -y nginx1

# Install PM2
echo "=== Installing PM2 ==="
npm install -g pm2
sudo ln -sf $(which pm2) /usr/bin/pm2

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
