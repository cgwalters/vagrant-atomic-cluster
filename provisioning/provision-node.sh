#!/bin/sh

hostname=$1

echo "Hello, I am a node." >> /etc/motd

exec hostnamectl set-hostname "${hostname}"
