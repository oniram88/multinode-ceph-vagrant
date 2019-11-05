# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"
  config.ssh.forward_agent = true
  config.ssh.insert_key = false
  config.hostmanager.enabled = true
  config.cache.scope = :box

  # We need one Ceph admin machine to manage the cluster
  config.vm.define "ceph-admin" do |admin|
    admin.vm.hostname = "ceph-admin"
    admin.vm.network :private_network, ip: "172.21.12.10"
    admin.vm.provision :shell, :inline => "DEBIAN_FRONTEND=noninteractive apt-get update && wget -q -O- 'https://download.ceph.com/keys/release.asc' | apt-key add - \
          && echo deb https://download.ceph.com/debian-nautilus/ $(lsb_release -sc) main | sudo tee /etc/apt/sources.list.d/ceph.list \
          && apt-get update && apt-get install -yq ntp ceph-deploy", :privileged => true
  end

  # The Ceph client will be our client machine to mount volumes and interact with the cluster
  config.vm.define "ceph-client" do |client|
    client.vm.hostname = "ceph-client"
    client.vm.network :private_network, ip: "172.21.12.11"
    # ceph-deploy will assume remote machines have python2 installed
    config.vm.provision :shell, :inline => "DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -yq python", :privileged => true
  end

  # We provision three nodes to be Ceph servers
  (1..3).each do |i|
    disk_base_name = "./volumes/disk#{i}.vdi"
    config.vm.define "ceph-server-#{i}" do |config|
      config.vm.hostname = "ceph-server-#{i}"
      config.vm.network :private_network, ip: "172.21.12.#{i + 11}"

      config.vm.provider "virtualbox" do |vb|
        unless File.exist?(disk_base_name)
          vb.customize ['createhd', '--filename', disk_base_name, '--variant', 'Fixed', '--size', 3 * 1024]
        end

        vb.customize [ 'storageattach',
                       :id, # the id will be replaced (by vagrant) by the identifier of the actual machine
                       '--storagectl', 'SCSI', # one of `SATA Controller` or `SCSI Controller` or `IDE Controller`;
                       # obtain the right name using: vboxmanage showvminfo
                       '--port', 2,     # port of storage controller. Note that port #0 is for 1st hard disk, so start numbering from 1.
                       '--device', 0,   # the device number inside given port (usually is #0)
                       '--type', 'hdd',
                       '--medium', disk_base_name]
      end

      # ceph-deploy will assume remote machines have python2 installed
      config.vm.provision :shell, :inline => "DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -yq python", :privileged => true
    end
  end
end
