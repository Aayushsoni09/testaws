#!/bin/bash
set -e
echo "=== Cleaning existing node_modules ==="
cd /var/www/nextjsproject
rm -rf node_modules
echo "✅ Cleanup done!"
