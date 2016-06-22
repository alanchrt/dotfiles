require 'yaml'

VAGRANTFILE_API_VERSION = "2"
VM_NAME = "dev"
VM_IP = "192.168.100.200"
VARS_FILE = "roles/dotfiles/vars/main.yml"

begin
  ANSIBLE_VARS = YAML.load_file(VARS_FILE)
rescue Errno::ENOENT
  ANSIBLE_VARS = {}
  ANSIBLE_VARS["git_name"] = [(print 'Git user.name: '), STDIN.gets.chomp][1]
  ANSIBLE_VARS["git_email"] = [(print 'Git user.email: '), STDIN.gets.chomp][1]
  f = File.new(VARS_FILE, 'w')
  YAML.dump(ANSIBLE_VARS, f)
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/trusty64"

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
    ansible.playbook = "#{File.dirname(__FILE__)}/playbook.yml"
  end
end
