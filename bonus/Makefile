K3D = sudo k3d
KUBECTL = sudo kubectl
HELM = sudo helm -n kube-system
ARGOCD = sudo argocd

all: cluster-create \
	helm-init gitlab-init \
	coredns-config add-host \
	wait-for-gitlab gitlab-create-repo \
	argocd-init apply-playground argocd-create-app \
	self-test gitlab-initial-password

CLUSTER_AGENTS = 1
CLUSTER_OPTS = --agents $(CLUSTER_AGENTS)
CLUSTER_OPTS += -p "80:80@loadbalancer" # gitlab wants 80...
CLUSTER_OPTS += -p "443:443@loadbalancer" # gitlab wants 443...
ifneq (,$(wildcard registry-config.yml))
# https://k3d.io/stable/usage/registries/
CLUSTER_OPTS += --registry-config registry-config.yml
endif
CLUSTER_NAME = mycluster

cluster-create:
	$(K3D) cluster create $(CLUSTER_OPTS) $(CLUSTER_NAME) || :

cluster-delete:
	$(K3D) cluster delete $(CLUSTER_NAME)

TRAEFIK_VERSION = 32.1.1

helm-init:
	$(HELM) repo add traefik https://traefik.github.io/charts
	$(HELM) repo add gitlab https://charts.gitlab.io/ || :
	$(HELM) repo update
	$(KUBECTL) apply --server-side --force-conflicts -k https://github.com/traefik/traefik-helm-chart/traefik/crds/
	$(HELM) install traefik traefik/traefik --version $(TRAEFIK_VERSION) || :

gitlab-init:
	$(KUBECTL) create namespace gitlab || :
	$(HELM) upgrade --install gitlab -n gitlab gitlab/gitlab \
		--timeout 600s \
		--set global.hosts.domain=demolinux.local \
		--set global.hosts.https=false \
		--set global.hosts.gitlab.https=false \
		--set certmanager.install=false \
		--set global.ingress.configureCertmanager=false
	$(KUBECTL) apply -f gitlab.yml

gitlab-initial-password:
	@$(KUBECTL) get secret -n gitlab gitlab-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode

gitlab-create-repo:
	./glab-clone-repo.sh

.ONESHELL:
wait-for-gitlab:
	while :; do
		echo waiting for gitlab...
		curl https://gitlab.demolinux.local/ -ks | grep -q sign_in && break
		sleep 1
	done

coredns-config:
	$(KUBECTL) apply -f coredns.yml -n kube-system
	$(KUBECTL) rollout restart deployment coredns -n kube-system

argocd-init:
	$(KUBECTL) create namespace argocd || :
	$(KUBECTL) apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
	$(KUBECTL) apply -n argocd -f argocd-cmd-params-cm.yaml
	$(KUBECTL) apply -f argocd.yaml

ARGOCD_REPO = http://gitlab.demolinux.local/root/repo.git
ARGOCD_REPO_SUBDIR = deployment # where to find the .yaml once cloned

argocd-login:
	$(ARGOCD) login \
		--grpc-web-root-path /argo-cd \
		--insecure localhost \
		--username admin --password $$(while :; do \
			pass=$$($(ARGOCD) admin initial-password -n argocd \
				2>/dev/null | head -1); \
			if [ -n "$$pass" ]; then \
				echo $$pass; \
				echo default password: $$pass >&2; \
				break; \
			else \
				sleep 1; \
			fi \
		done);

argocd-initial-password:
	$(ARGOCD) admin initial-password -n argocd

argocd-create-app:
	while true; do \
		if $(MAKE) -s argocd-login; then \
			break; \
		fi; \
		echo argocd not yet started...; \
		sleep 5; \
	done

	$(ARGOCD) app create playground \
		--repo $(ARGOCD_REPO) \
		--path $(ARGOCD_REPO_SUBDIR) \
		--dest-server https://kubernetes.default.svc \
		--dest-namespace default --upsert \
		--insecure
	$(MAKE) -s argocd-sync

argocd-sync:
	$(ARGOCD) app sync playground

create-dev-namespace:
	$(KUBECTL) create namespace dev || :

apply-playground: create-dev-namespace
	$(KUBECTL) apply -f playground.yaml

self-test:
	./test.sh

add-host:
	echo '127.0.0.1 gitlab.demolinux.local' | sudo tee -a /etc/hosts

restart:
	$(K3D) cluster stop $(CLUSTER_NAME)
	$(K3D) cluster start $(CLUSTER_NAME)

re: cluster-delete all

.PHONY: cluster-create cluster-delete \
	apply-playground self-test re
