#!/bin/bash

echo "Configuring NTOS-Server..."

cp -rnv /app/* /data

echo "Linking..."
ln -sv /data/assets /var/www/localhost/htdocs/assets
ln -sv /data/configs /var/www/localhost/htdocs/configs 
ln -sv /data/credcon /var/www/localhost/htdocs/credcon 
ln -sv /data/rdp /var/www/localhost/htdocs/rdp
ln -sv /data/VERSION /var/www/localhost/htdocs/VERSION

echo "Done. Starting Apache2 webserver..."

httpd -D FOREGROUND &

echo "Started Apache2 server."
sleep infinity