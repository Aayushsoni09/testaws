#!/bin/bash

# Start and enable NGINX
sudo systemctl start nginx
sudo systemctl enable nginx

# Start Next.js app using PM2
cd /var/www/nextjsproject
pm2 start npm --name "nextjsproject" -- start
pm2 save
pm2 startup systemd