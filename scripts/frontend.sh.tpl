#!/bin/bash
sudo apt update && sudo apt install nodejs npm nginx -y
sudo npm install -g pm2

cd /home/ubuntu
sudo -u ubuntu git clone https://github.com/pravinmishraaws/book-review-app.git
cd /home/ubuntu/book-review-app/frontend
sudo -u ubuntu npm install

# REMOVED SINGLE QUOTES AROUND EOF
cat << EOF > .env.local
NEXT_PUBLIC_API_URL=/api
EOF

chown ubuntu:ubuntu .env.local

sudo -u ubuntu npm run build
sudo -u ubuntu pm2 start npm --name "frontend" -- run start
sudo -u ubuntu pm2 save
env PATH=$PATH:/usr/bin pm2 startup systemd -u ubuntu --hp /home/ubuntu

cat << 'NGINX' > /etc/nginx/sites-available/default
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

    location /api/ {
        rewrite ^/api/(.*) /$1 break;
        proxy_pass http://${internal_alb_dns};
        proxy_http_version 1.1;
        proxy_set_header Host $host;
    }
}
NGINX

sudo nginx -t && sudo systemctl restart nginx
