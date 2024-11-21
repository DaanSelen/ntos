#!/bin/bash

echo "Starting NTOS-Server..."

httpd -D FOREGROUND &

echo "Started Apache2 server."
sleep infinity
