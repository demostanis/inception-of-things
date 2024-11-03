VAGRANT = vagrant

up:
	$(VAGRANT) up

halt:
	$(VAGRANT) halt
down: halt # alias

provision:
	$(VAGRANT) provision

re: down up

S:
	$(VAGRANT) ssh cgodardS

SW:
	$(VAGRANT) ssh cgodardSW

VAGRANT_INSTALL_PATH = /opt/vagrant
VAGRANT_PATCH = vagrant-support-vbox-7.1.patch
patch-vagrant:
	patch -d $(VAGRANT_INSTALL_PATH) -p0 <$(VAGRANT_PATCH) || \
		echo patch failed. are you running as root? >&2

.PHONY: up patch-vagrant
