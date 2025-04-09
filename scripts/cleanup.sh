#!/bin/bash
set -e

echo "=== Cleaning existing files ==="
cd /var/www/nextjsproject || exit 1

# Delete previous Next.js build and node_modules
rm -rf .next
rm -rf node_modules
rm -f package-lock.json
echo "✅ Cleanup done!"
