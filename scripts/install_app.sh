#!/bin/bash
set -e

echo "=== Installing app dependencies ==="
cd /var/www/nextjsproject || { echo "❌ Failed to enter /var/www/nextjsproject"; exit 1; }

# Forcefully change ownership to ec2-user
sudo chown -R ec2-user:ec2-user /var/www/nextjsproject

npm install --production || { echo "❌ npm install failed"; exit 1; }
sudo chmod -R u+rw /var/www/nextjsproject

echo "✅ App dependencies installed!"
