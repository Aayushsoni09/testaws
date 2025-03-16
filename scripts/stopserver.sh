#!/bin/bash

# Check if NGINX is running and stop it
isExistApp="$(pgrep nginx)"
if [[ -n $isExistApp ]]; then
    sudo systemctl stop nginx.service
fi

# Check if PM2 is running any process and stop all
isExistApp="$(pgrep PM2)"
if [[ -n $isExistApp ]]; then
    pm2 stop all
fi

