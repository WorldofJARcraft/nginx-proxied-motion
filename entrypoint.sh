#!/bin/sh

echo "Setting up wireguard interface"
wg-quick up wg0

echo "Starting motion"
motion -c /etc/motion/motion.conf -n 
