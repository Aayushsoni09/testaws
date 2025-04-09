#!/bin/bash
set -e

echo "=== Installing app dependencies ==="
cd /var/www/nextjsproject
npm install --production || { echo "❌ npm install failed"; exit 1; }
sudo chown -R ec2-user:ec2-user /var/www/nextjsproject  # Ensure ec2-user owns everything
sudo chmod -R u+rw /var/www/nextjsproject  # Ensure write permissions
echo "✅ App dependencies installed!"

