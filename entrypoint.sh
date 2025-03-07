#!/bin/bash

echo "Configuring NTOS-Server..."

cp -rv /app/* /data

echo "Linking..."
ln -s /data/assets /var/www/localhost/htdocs/assets
ln -s /data/configs /var/www/localhost/htdocs/configs 
ln -s /data/credcon /var/www/localhost/htdocs/credcon 
ln -s /data/rdp /var/www/localhost/htdocs/rdp

echo "Done. Starting Apache2 webserver..."

httpd -D FOREGROUND &

echo "Started Apache2 server."
sleep infinity
