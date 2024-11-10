K3D = sudo k3d
KUBECTL = sudo kubectl
HELM = sudo helm -n kube-system
ARGOCD = sudo argocd

TRAEFIK_VERSION = 32.1.1

CLUSTER_AGENTS = 1
CLUSTER_OPTS = --agents $(CLUSTER_AGENTS)
CLUSTER_OPTS += -p "8888:80@loadbalancer" # expose traefik
CLUSTER_NAME = mycluster

all: cluster-create helm-init argocd-init apply-playground self-test

cluster-create:
	$(K3D) cluster create $(CLUSTER_OPTS) $(CLUSTER_NAME) || :

cluster-delete:
	$(K3D) cluster delete $(CLUSTER_NAME)

helm-init:
	$(HELM) repo add traefik https://traefik.github.io/charts
	$(HELM) repo update
	$(KUBECTL) apply --server-side --force-conflicts -k https://github.com/traefik/traefik-helm-chart/traefik/crds/
	$(HELM) install traefik traefik/traefik --version $(TRAEFIK_VERSION) || :

argocd-init:
	$(KUBECTL) create namespace argocd || :
	$(KUBECTL) apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
	$(KUBECTL) apply -n argocd -f argocd-cmd-params-cm.yaml
	#$(ARGOCD) admin initial-password -n argocd
	$(KUBECTL) apply -f argocd.yaml

create-dev-namespace:
	$(KUBECTL) create namespace dev || :

apply-playground: create-dev-namespace
	$(KUBECTL) apply -f playground.yaml

self-test:
	./test.sh

restart:
	$(K3D) cluster stop $(CLUSTER_NAME)
	$(K3D) cluster start $(CLUSTER_NAME)

re: cluster-delete all

.PHONY: cluster-create cluster-delete \
	apply-playground self-test re
