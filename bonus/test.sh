#!/bin/sh

k='sudo kubectl'

attempts=0
while :; do
	# give some time for the container to actually start...
	playground_test=$(curl -s localhost/playground | grep -q '"status":"ok"';
		echo $?)
	argocd_test=$(curl -s localhost/argo-cd/ | grep -q '<title>Argo';
		echo $?)

	if [ "$playground_test" != 0 -o "$argocd_test" != 0 ]; then
		if (( attempts > 120 )); then
			echo something went wrong, the app was not correctly deployed
			exit 1
		fi
		(( attempts+=1 ))
		sleep 1
	else
		break
	fi
done
