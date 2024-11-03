#!/bin/sh

set -e

mount -t cgroup cgroup /sys/fs/cgroup || :

cat >/etc/cgconfig.conf<<EOF
mount {
	cpuacct = /cgroup/cpuacct;
	memory = /cgroup/memory;
	devices = /cgroup/devices;
	freezer = /cgroup/freezer;
	net_cls = /cgroup/net_cls;
	blkio = /cgroup/blkio;
	cpuset = /cgroup/cpuset;
	cpu = /cgroup/cpu;
}
EOF
