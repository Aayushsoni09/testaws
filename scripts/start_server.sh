#!/bin/bash
set -e

echo "=== Starting server ==="
echo "Current working directory: $(pwd)"
echo "Contents:"
ls -la

# === Step 1: Ensure Nginx is up and running ===
echo "=== Checking Nginx ==="
if ! systemctl is-active --quiet nginx; then
    sudo systemctl start nginx || { echo "❌ Failed to start Nginx"; exit 1; }
fi
sudo systemctl enable nginx || { echo "❌ Failed to enable Nginx"; exit 1; }

# === Step 2: Start Next.js app with PM2 ===
echo "=== Starting Next.js app with PM2 ==="

# Dynamically determine the app root (one level above scripts/)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_ROOT="$(dirname "$SCRIPT_DIR")"

echo "Changing to app directory: $APP_ROOT"
cd "$APP_ROOT" || { echo "❌ Failed to change to app directory"; exit 1; }

# Install dependencies (optional, but safe)
echo "Installing dependencies..."
npm install || { echo "❌ npm install failed"; exit 1; }

# Build the app
echo "Building the app..."
npm run build || { echo "❌ npm run build failed"; exit 1; }

# Start app with PM2
echo "Starting app with PM2..."
pm2 start npm --name "nextjsproject" -- start || { echo "❌ PM2 failed to start app"; exit 1; }
pm2 save || { echo "❌ PM2 save failed"; exit 1; }

# Set up PM2 to run on system boot as ec2-user
echo "=== Setting up PM2 startup ==="
pm2 startup systemd -u ec2-user --hp /home/ec2-user || { echo "❌ PM2 startup setup failed"; exit 1; }
sudo systemctl enable pm2-ec2-user || { echo "❌ Failed to enable PM2 service"; exit 1; }

# === Step 3: Update Nginx config for reverse proxy ===
echo "=== Updating Nginx to reverse proxy ==="
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

# Test and reload Nginx
echo "=== Testing updated Nginx config ==="
sudo nginx -t || { echo "❌ Nginx config test failed"; exit 1; }

echo "=== Reloading Nginx ==="
sudo systemctl reload nginx || { echo "❌ Failed to reload Nginx"; exit 1; }

echo "✅ Server started successfully!"
