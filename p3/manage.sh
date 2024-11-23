#!/usr/bin/sh

# Executables
K3D=k3d
KUBECTL=kubectl
HELM='helm -n kube-system'
ARGOCD=argocd

#==============================================================================#
# Settings
#==============================================================================#

# Traefik
TRAEFIK_VERSION='32.1.1'
TRAEFIK_CHART='https://traefik.github.io/charts'

# ArgoCD
ARGOCD_REPO='https://github.com/demostanis/amassias-iot.git'
ARGOCD_REPO_SUBDIR='deployment' # where to find the .yaml once cloned
ARGOCD_INSTALLER='https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml'

# Cluster
CLUSTER_NAME=mycluster
CLUSTER_AGENTS=1
CLUSTER_OPTS="--agents $CLUSTER_AGENTS"
CLUSTER_OPTS="$CLUSTER_OPTS -p 8888:80@loadbalancer" # TODO: render this modular

#==============================================================================#
# Help
#==============================================================================#

show_arg()
{
	echo -e "\t$1 - $2"
}

show_help()
{
	echo "Usage: $0 [MODE]"
	echo 'Modes:'
	show_arg 'initialize' 'Initializes the cluster.'
	show_arg 'stop' 'Stops the cluster.'
	show_arg 'resume' 'Resumes the cluster.'
	show_arg 'restart' 'Restarts the cluster.'
	show_arg 'heath' 'Heath check the cluster.'
	show_arg 'destroy' 'Stops and destroys the cluster.'
	show_arg 'help' 'Shows this help.'
}

help()
{
	show_help
	exit
}

#==============================================================================#
# Error management
#==============================================================================#

error_help()
{
	show_help 1>&2
	exit 1
}

error_unexpected_argument()
{
	(echo -e "Unexpected argument." ; echo) 1>&2
	error_help
}

error_expected_argument()
{
	(echo -e "Expected argument."; echo) 1>&2
	error_help
}

error_unknown_argument()
{
	(echo -e "Unknown argument."; echo) 1>&2
	error_help
}

error_root()
{
	echo 'You must have root privileges to run this program.' 1>&2
	exit 1
}

#==============================================================================#
# Health
#==============================================================================#

health()
{
	attempts=0
	unset HEALTHY
	while true
	do
		# give some time for the container to actually start...
		playground_test=$(curl -s localhost:8888 | grep -q '"status":"ok"'; echo $?)
		argocd_test=$(curl -s localhost:8888/argo-cd/ | grep -q '<title>Argo'; echo $?)
		if ! [ "$playground_test" != 0 -o "$argocd_test" != 0 ]; then
			HEALTHY=1
			break
		fi
		if (( attempts > 30 )); then
			break;
		fi
		(( attempts+=1 ))
		echo -n .
		sleep 1
	done
	# Prints newline if an attempt was already made
	if (( attempts > 0 )); then
		echo
	fi
	test $HEALTHY					\
		&& echo 'App seems healthy'	\
		|| echo something went wrong, the app was not correctly deployed 1>&2
	test $HEALTHY
}

#==============================================================================#
# ArgoCD helpers
#==============================================================================#

argocd_login()
{
	while true
	do
		pass=$($ARGOCD admin initial-password -n argocd 2>/dev/null | head -1)
		if [ -n "$pass" ]
		then
			echo default password: $pass >&2
			break
		fi
		sleep 1
	done
	$ARGOCD login											\
		--grpc-web-root-path /argo-cd						\
		--plaintext --insecure localhost:8888				\
		--username admin --password $pass
}

argocd_sync()
{
	$ARGOCD app sync playground
}

#==============================================================================#
# Initialization
#==============================================================================#

initialize_cluster()
{
	$K3D cluster create $CLUSTER_OPTS $CLUSTER_NAME
}

initialize_helm()
{
	$HELM repo add traefik $TRAEFIK_CHART
	$HELM repo update
	$KUBECTL apply --server-side --force-conflicts -k https://github.com/traefik/traefik-helm-chart/traefik/crds/
	$HELM install traefik traefik/traefik --version $TRAEFIK_VERSION
}

initialize_argocd()
{
	$KUBECTL create namespace argocd
	$KUBECTL apply -n argocd -f $ARGOCD_INSTALLER
	$KUBECTL apply -n argocd -f argocd-cmd-params-cm.yaml
	$KUBECTL apply -f argocd.yaml
}

initialize_playground()
{
	$KUBECTL create namespace dev
	$KUBECTL apply -f playground.yaml
}

initialize_argocd_app()
{
	while true
	do
		if argocd_login >/dev/null 2>&1
		then
			break
		fi
		echo argocd not yet started...
		sleep 5
	done

	$ARGOCD app create playground						\
		--repo $ARGOCD_REPO								\
		--path $ARGOCD_REPO_SUBDIR						\
		--dest-server https://kubernetes.default.svc	\
		--dest-namespace default --upsert
	argocd_sync >/dev/null 2>&1
}

#==============================================================================#
# State management
#==============================================================================#

initialize()
{
	initialize_cluster
	initialize_helm
	initialize_argocd
	initialize_playground
	initialize_argocd_app
	health
}

stop()
{
	$K3D cluster stop $CLUSTER_NAME
}

resume()
{
	$K3D cluster start $CLUSTER_NAME
}

restart()
{
	stop
	resume
}

destroy()
{
	stop
	$K3D cluster delete $CLUSTER_NAME
}

rebuild()
{
	destroy
	initialize
}

#==============================================================================#
# Prerequisites
#==============================================================================#

# Check if user has root privileges
sudo -n true >/dev/null 2>&1 || error_root

# Only one argument is expected
test -z $1 && error_expected_argument
test -z $2 || error_unexpected_argument

#==============================================================================#
# Starting in chosen mode
#==============================================================================#

case "$1" in
	initialize)	;;
	stop)		;;
	resume)		;;
	restart)	;;
	health)		;;
	destroy)	;;
	help)		;;
	rebuild)	;;
	*)
		error_unknown_argument
		;;
esac

$1
exit $?