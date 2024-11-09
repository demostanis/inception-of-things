#!/bin/sh

k='sudo kubectl'

is_ready() {
	[ $($k get -n dev deployment | awk 'NR==2{print$2}') = 1/1 ]
}

delay() {
	sleep 1
}

until is_ready; do delay; done

attempts=0
# give some time for the container to actually start...
while ! curl -s localhost:8888 | grep -q '"status":"ok"'; do
	if (( attempts > 60 )); then
		echo something went wrong, the app was not correctly deployed
		exit 1
	fi
	(( attempts+=1 ))
	delay
done
