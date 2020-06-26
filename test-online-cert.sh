#!/bin/bash
set -e


if [ "$#" -eq 1 ]; then
  DIR=test-online-cert
  DOMAIN=$1
else
  echo "Usage: $0 domain-name"
  exit -1
fi

sudo rm -Rf $DIR
mkdir $DIR
cd $DIR

cp ../req-online-cert/etc/live/$DOMAIN/*.pem .
tee nginx.conf <<EOF
server {
    listen       80;
    listen 443   ssl;
    server_name  $DOMAIN;
    ssl_certificate "/etc/nginx/ssl/fullchain.pem";
    ssl_certificate_key "/etc/nginx/ssl/privkey.pem";
    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}
EOF
tee docker-compose.yml <<EOF
version: '3.1'
services:
  letsencrypt-nginx-container:
    container_name: 'letsencrypt-nginx-container'
    image: nginx:1.17.9
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/conf.d/default.conf
      - ./fullchain.pem:/etc/nginx/ssl/fullchain.pem
      - ./privkey.pem:/etc/nginx/ssl/privkey.pem
EOF
docker-compose up -d
cd ..

curl http://$DOMAIN
curl -k https://$DOMAIN
