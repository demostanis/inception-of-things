Vagrant.configure("2") do |config|
  config.vm.box = "generic/alpine318"

  # to share the k3s token between hosts
  config.vm.synced_folder "shared", "/vagrant"

  # k3s server
  config.vm.define "cgodardS" do |server|
    server.vm.network "private_network", ip: "192.168.56.110"
    server.vm.provision "shell",
      path: "guests/setup_k3s.sh",
      args: "server"
  end

  # k3s server worker
  config.vm.define "cgodardSW" do |worker|
    worker.vm.network "private_network", ip: "192.168.56.111"
    worker.vm.provision "shell",
      path: "guests/setup_k3s.sh",
      args: "agent"
  end

  config.vm.provider "virtualbox" do |vb|
    # as recommended by the subject
    vb.memory = "1024"#MiB
    vb.cpus = 2
  end
end

# -*- mode: ruby -*-
# vi: set ft=ruby :
