#!/bin/sh -e

if ! grep -q 'I am master' /etc/motd; then
    echo "Hello, I am master." >> /etc/motd
fi

cat > /etc/tmpfiles.d/kubernetes.conf <<EOF
d /run/kubernetes 0755 kube kube -
EOF
systemd-tmpfiles --create --boot --prefix=/run/kubernetes

# https://github.com/GoogleCloudPlatform/kubernetes/pull/3602
mkdir -p /run/kubernetes
chown kube:kube /run/kubernetes

exec hostnamectl set-hostname master
