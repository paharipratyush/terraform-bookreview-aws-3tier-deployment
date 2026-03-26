#!/bin/bash
sudo apt update && sudo apt install nodejs npm mysql-client-core-8.0 -y
sudo npm install -g pm2

cd /home/ubuntu
sudo -u ubuntu git clone https://github.com/pravinmishraaws/book-review-app.git
cd /home/ubuntu/book-review-app/backend
sudo -u ubuntu npm install

# CRITICAL FIX: Changed DB_PASSWORD to DB_PASS
cat << EOF > .env
DB_HOST=${db_host}
DB_USER=admin
DB_PASS=${db_pass}
DB_NAME=bookreview
DB_DIALECT=mysql
PORT=3001
JWT_SECRET=mysecret
ALLOWED_ORIGINS=http://${public_alb_dns}
EOF

chown ubuntu:ubuntu .env

while ! mysql -h ${db_host} -u admin -p"${db_pass}" -e "SELECT 1" >/dev/null 2>&1; do
  sleep 5
done

mysql -h ${db_host} -u admin -p"${db_pass}" -e "CREATE DATABASE IF NOT EXISTS bookreview;"

sudo -u ubuntu pm2 start src/server.js --name "backend"
sudo -u ubuntu pm2 save
env PATH=$PATH:/usr/bin pm2 startup systemd -u ubuntu --hp /home/ubuntu
