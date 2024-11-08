################################################################################
# Config
################################################################################

include .env

SERVER_HOSTNAME			=	$(LOGIN_42)S
WORKER_HOSTNAME			=	$(LOGIN_42)SW

VBOX_VM_PREFIX			=	$(shell basename $$PWD)
VBOX_VM_SERVER			=	$(VBOX_VM_PREFIX)_$(SERVER_HOSTNAME)
VBOX_VM_WORKER			=	$(VBOX_VM_PREFIX)_$(WORKER_HOSTNAME)

VBOX_PATH				=	$(HOME)/VirtualBox VMs/
VAGRANT					=	./launch_vagrant.sh
VAGRANT_INSTALL_PATH	=	/opt/vagrant
VAGRANT_PATCH			=	vagrant-support-vbox-7.1.patch

################################################################################
# Rules
################################################################################

all: up

up:
	@$(VAGRANT) up

halt:
	@$(VAGRANT) halt

down: halt # alias

provision:
	@$(VAGRANT) provision

re: down up

clear:
	$(RM) -r .vagrant
	$(RM) -r "$(VBOX_PATH)"/$(VBOX_VM_SERVER)_*
	$(RM) -r "$(VBOX_PATH)"/$(VBOX_VM_WORKER)_*

reeee: down clear up

################################################################################
# SSH Connections
################################################################################

S:
	@$(VAGRANT) ssh $(SERVER_HOSTNAME)

SW:
	@$(VAGRANT) ssh $(WORKER_HOSTNAME)

################################################################################
# Setup & patching
################################################################################

setup:
	[ $$(id -u) = 0 ] || echo setup requires root >&2
	pacman -S vagrant virtualbox virtualbox-host-modules-arch --noconfirm
	for m in vboxdrv vboxnetadp vboxnetflt; do modprobe $$m; done
	$(MAKE) patch-vagrant

patch-vagrant:
	patch -d $(VAGRANT_INSTALL_PATH) -p0 <$(VAGRANT_PATCH) || \
		echo patch failed. are you running as root? >&2

################################################################################
# Fuck Virtual Box
################################################################################

fuck-vbox:
	sudo pkill VBoxHeadless

################################################################################
# Phony rules
################################################################################

.PHONY: all				\
		up				\
		halt			\
		down			\
		provision		\
		re				\
		clear			\
		reeee			\
		S				\
		SW				\
		setup			\
		patch-vagrant	\
		fuck-vbox
