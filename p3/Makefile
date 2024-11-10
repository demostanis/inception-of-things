K3D = sudo k3d
KUBECTL = sudo kubectl
HELM = sudo helm -n kube-system

CLUSTER_AGENTS = 1
CLUSTER_OPTS = --agents $(CLUSTER_AGENTS)
CLUSTER_OPTS += -p "8888:80@loadbalancer" # expose traefik
CLUSTER_NAME = mycluster

all: cluster-create helm-init apply-playground self-test

cluster-create:
	$(K3D) cluster create $(CLUSTER_OPTS) $(CLUSTER_NAME) || :

cluster-delete:
	$(K3D) cluster delete $(CLUSTER_NAME)

helm-init:
	$(HELM) repo add traefik https://traefik.github.io/charts
	$(HELM) repo update
	$(HELM) install traefik traefik/traefik

create-dev-namespace:
	$(KUBECTL) create namespace dev || :

apply-playground: create-dev-namespace
	$(KUBECTL) apply -f playground.yaml

self-test:
	./test.sh

re: cluster-delete all

.PHONY: cluster-create cluster-delete \
	apply-playground self-test re \
	demolinux-specific
