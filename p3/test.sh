#!/bin/sh

k='sudo kubectl'

attempts=0
# give some time for the container to actually start...
while ! curl -s localhost:8888 | grep -q '"status":"ok"'; do
	if (( attempts > 60 )); then
		echo something went wrong, the app was not correctly deployed
		exit 1
	fi
	(( attempts+=1 ))
	sleep 1
done
