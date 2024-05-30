#!/bin/sh

echo "Setting up wireguard interface"
wg-quick up wg0

echo "Starting motion"
motion -c /etc/motion/motion.conf -n &

echo "Starting SimpleHttpServer"
cd /capture; python3 -m http.server 8082 &

wait
