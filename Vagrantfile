# -*- mode: ruby -*-
# vi: set ft=ruby :

#$script = <<SCRIPT
#apt update
#apt install -y python
#SCRIPT

Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/xenial64"
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.provider "virtualbox" do |vb|
    vb.gui = false
    vb.memory = "512"
  end

  config.vm.synced_folder ".", "/vagrant", disabled: true
 
  config.vm.define "lb" do |lb|
  	lb.vm.hostname = "loadbalancer"
 	lb.vm.network "private_network", ip: "10.0.0.100"
        lb.vm.provider "virtualbox" do |vb|
		vb.name = "k8s-loadbalancer"
		vb.customize ["modifyvm", :id, "--memory", "256"]
	end
  end
 
  config.vm.define "master1" do |master1|
  	master1.vm.hostname = "k8s-master1"
  	master1.vm.network "private_network", ip: "10.0.0.101"
        master1.vm.provider "virtualbox" do |vb|
		vb.name = "k8s-master1"
	end
  end

  config.vm.define "master2" do |master2|
  	master2.vm.hostname = "k8s-master2"
  	master2.vm.network "private_network", ip: "10.0.0.102"
        master2.vm.provider "virtualbox" do |vb|
		vb.name = "k8s-master2"
	end
  end

  config.vm.define "master3" do |master3|
  	master3.vm.hostname = "k8s-master3"
  	master3.vm.network "private_network", ip: "10.0.0.103"
        master3.vm.provider "virtualbox" do |vb|
		vb.name = "k8s-master3"
	end
  end

  config.vm.define "worker1" do |worker1|
  	worker1.vm.hostname = "k8s-worker1"
  	worker1.vm.network "private_network", ip: "10.0.0.110"
        worker1.vm.provider "virtualbox" do |vb|
		vb.name = "k8s-worker1"
	end
  end

  config.vm.define "worker2" do |worker2|
  	worker2.vm.hostname = "k8s-worker2"
  	worker2.vm.network "private_network", ip: "10.0.0.111"
        worker2.vm.provider "virtualbox" do |vb|
		vb.name = "k8s-worker2"
	end
  end
  
  config.vm.define "worker3" do |worker3|
  	worker3.vm.hostname = "k8s-worker3"
  	worker3.vm.network "private_network", ip: "10.0.0.112"
        worker3.vm.provider "virtualbox" do |vb|
		vb.name = "k8s-worker3"
	end
  end
  
  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "ssh.yml"
  end

end
