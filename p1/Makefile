VAGRANT = vagrant

up:
	$(VAGRANT) up

halt:
	$(VAGRANT) halt
down: halt # alias

provision:
	$(VAGRANT) provision

re: down up

VBOX_PATH = $(HOME)/VirtualBox VMs/
clear:
	$(RM) -r .vagrant
	$(RM) -r "$(VBOX_PATH)"/inception-of-things_cgodardS*

fuck-vbox:
	sudo pkill VBoxHeadless

reeee: down clear up

S:
	$(VAGRANT) ssh cgodardS

SW:
	$(VAGRANT) ssh cgodardSW

setup:
	[ $$(id -u) = 0 ] || echo setup requires root >&2
	pacman -S vagrant virtualbox virtualbox-host-modules-arch --noconfirm
	for m in vboxdrv vboxnetadp vboxnetflt; do modprobe $$m; done
	$(MAKE) patch-vagrant

VAGRANT_INSTALL_PATH = /opt/vagrant
VAGRANT_PATCH = vagrant-support-vbox-7.1.patch
patch-vagrant:
	patch -d $(VAGRANT_INSTALL_PATH) -p0 <$(VAGRANT_PATCH) || \
		echo patch failed. are you running as root? >&2

.PHONY: up halt down provision re clear reeee S SW setup patch-vagrant
