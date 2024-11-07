#!/bin/bash

set -e

export TOKEN_LOCATION=/var/lib/rancher/k3s/server/token
export CONF_LOCATION=/etc/rancher/k3s/k3s.yaml
export SERVER_HOST=192.168.56.110
export K3S_URL=https://$SERVER_HOST:6443 # defined in the Vagrantfile
export INSTALL_K3S_EXEC="$1"

for=$1

install()
{
	hostname "alpine-$for"
	curl -sfL https://get.k3s.io | sh -
}

case "$for" in
	server)
		INSTALL_K3S_EXEC+=" --tls-san $SERVER_HOST"
		INSTALL_K3S_EXEC+=" --write-kubeconfig-mode 644"
		install $1

		until [ -e "$TOKEN_LOCATION" ]; do sleep 1; done
		sed s/127.0.0.1/$SERVER_HOST/g "$CONF_LOCATION">/vagrant/conf
		cat "$TOKEN_LOCATION" >/vagrant/token
		;;
	agent)
		INSTALL_K3S_EXEC+=" --server=$K3S_URL"
		export K3S_TOKEN=$(</vagrant/token)
		install $1

		# to kubectl from the agent
		mkdir -p /home/vagrant/.kube
		cp /vagrant/conf /home/vagrant/.kube/config
		;;
	*)
		echo unknown argument $1 >&2
		;;
esac
