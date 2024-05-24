#!/bin/sh


echo "Setting up wireguard interface"
wg-quick up wg0

echo "Starting nginx"
nginx -g 'daemon off;'
