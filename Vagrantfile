require 'yaml'

VAGRANTFILE_API_VERSION = "2"
VM_NAME = "dev"
VM_IP = "192.168.100.200"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/wily64"

  config.vm.hostname = VM_NAME
  config.vm.network :private_network, ip: VM_IP
  config.vm.define VM_NAME.to_sym do |rails|
  end

  config.ssh.insert_key = false
  config.ssh.forward_agent = true

  config.vm.synced_folder ENV.fetch("DEV_VM_SYNCED_FOLDER", Dir.home), "/host"

  config.vm.provider :virtualbox do |v|
    v.name = VM_NAME
    v.memory = 4096
    v.cpus = 2
    v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    v.customize ["modifyvm", :id, "--ioapic", "on"]
  end
  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "#{File.dirname(__FILE__)}/playbooks/headless.yml"
  end
end
