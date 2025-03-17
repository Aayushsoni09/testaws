version: 0.2
phases:
  install:
    commands:
      - sudo amazon-linux-extras enable nodejs18
      - sudo yum clean metadata
      - sudo yum install -y nodejs npm
      - node -v
      - npm -v
      - sudo npm install -g pm2
      - sudo amazon-linux-extras enable nginx1
      - sudo yum install -y nginx
      - sudo mkdir -p /etc/nginx/conf.d
      - sudo tee /etc/nginx/conf.d/nextjs_proxy.conf > /dev/null <<EOF
        server {
            listen 80;
            server_name _;
            location / {
                proxy_pass http://localhost:3000;
                proxy_http_version 1.1;
                proxy_set_header Upgrade \$http_upgrade;
                proxy_set_header Connection 'upgrade';
                proxy_set_header Host \$host;
                proxy_cache_bypass \$http_upgrade;
            }
        }
        EOF
      - sudo systemctl start nginx
      - sudo systemctl enable nginx
