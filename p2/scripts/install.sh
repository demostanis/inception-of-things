#!/bin/sh

# Setting up ENV
set -a
source /conf/.env
export HOME='/home/vagrant'
export KUBECTL='/usr/local/bin/kubectl'

# K3S installation configuraion
export INSTALL_K3S_VERSION="$K3S_VERSION"
export INSTALL_K3S_EXEC="server \
	--write-kubeconfig-mode 644 \
	--node-external-ip=$SERVER_IP \
	--bind-address=$SERVER_IP"

# Setting up hosts
echo "127.0.1.1 $(hostname)" >> /etc/hosts
echo "::1 $(hostname)" >> /etc/hosts

# Installing K3S
echo -n 'Installing K3S' && [ -z $K3S_VERSION ] && echo || echo " ($K3S_VERSION)"
curl -sfL https://get.k3s.io | sh -

# Applying config
for app in app-one; do
	echo "[$app] - Initializing..."
	$KUBECTL create configmap "$app-web" --from-file "/conf/$app/index.html"
	$KUBECTL apply -f /conf/"$app"/deployment.yaml
	$KUBECTL apply -f /conf/"$app"/service.yaml
done

echo "[Ingress] - Initiating..."
$KUBECTL apply -f /conf/ingress.yaml
echo "[Ingress] - Done"
