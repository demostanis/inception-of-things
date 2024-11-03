#!/bin/sh

set -e

apk add k3s
sed -i 's/K3S_OPTS=.*/K3S_OPTS=$1/' /etc/conf.d/k3s
rc-update add k3s default
rc-service k3s start
