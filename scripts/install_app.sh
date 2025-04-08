#!/bin/bash
set -e

echo "=== Installing app dependencies ==="
cd /var/www/nextjsproject
npm install --production || { echo "❌ npm install failed"; exit 1; }
chown -R ec2-user:ec2-user .  # Ensure ec2-user owns everything
chmod -R u+rw .  # Ensure write permissions
echo "✅ App dependencies installed!"

