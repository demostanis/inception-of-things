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
	--bind-address=$SERVER_IP \
	--tls-san $SERVER_IP \
	--write-kubeconfig-mode 644"

# Disableing IPV6, because it's shit.
# "A problem ?" IPV6 fucked up something for sure
sysctl -w net.ipv6.conf.all.disable_ipv6=1

# Installing K3S
echo -n 'Installing K3S' && [ -z $K3S_VERSION ] && echo || echo " ($K3S_VERSION)"
curl -sfL https://get.k3s.io | sh -

# Waiting for k3s API server to have started
echo "[k3s] - Initializing..."
while ! nc -z $SERVER_IP 6443; do
	sleep 1
done
echo '[k3s] - Done'

# Because fuck my life, that's why
sleep 2

# Applying config
for app in app-one app-two app-three; do
	echo "[$app] - Initializing..."
	$KUBECTL create configmap "$app-web" --from-file "/conf/$app/index.html"
	$KUBECTL apply -f /conf/"$app"/deployment.yaml
	$KUBECTL apply -f /conf/"$app"/service.yaml
	echo "[$app] - Done"
done

echo "[Ingress] - Initializing..."
$KUBECTL apply -f /conf/ingress.yaml
echo "[Ingress] - Done"
