#!/bin/bash
set -e

echo "=== Installing app dependencies ==="
cd /var/www/nextjsproject
npm install --production || { echo "❌ npm install failed"; exit 1; }
echo "✅ App dependencies installed!"
