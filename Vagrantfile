# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

if ! File.exist?("provisioning/kubernetes-ansible/setup.yml")
  raise "Missing provisioning/kubernetes-ansible/setup.yml; try: git submodule update --init"
end

settings = YAML.load_file 'config.yml'

$DISTRO_BOXES = {
  "f22" => {"baseurl" => "https://dl.fedoraproject.org/pub/alt/fedora-atomic/images/f22/20150304.2/cloud/images/",
            "prefix" => "fedora-atomic-cloud-"}
}

$boxsettings = settings['box']
if ! $boxsettings
  raise "Missing 'box' in config.yml"
end
$clustersettings = settings['cluster']
if ! $clustersettings
  $clustersettings = {}
end

$distro = $boxsettings['distro']
if ! $distro
  raise "Missing box/distro in config.yml"
end
$distrodata = $DISTRO_BOXES[$distro]
if ! $distrodata
  raise "Unknown box/distro " + $distro
end
$baseurl = $distrodata["baseurl"] + $distrodata["prefix"]

$NUM_NODE = $clustersettings['n_nodes'] || 2
$MEMORY = 1024

$nodes = [];
$ansible_groups = {
  "masters" => ["master"],
  "etcd" => ["master"],
  "minions" => $nodes
}
$NUM_NODE.times do |i|
  $nodes.push("node-#{i+1}")
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = $distro + "-atomic-host"
  config.vm.box_url = $baseurl + "vagrant-libvirt.box"

  config.vm.provider :virtualbox do |v, override|
    override.vm.box_url = $baseurl + $distro + "vagrant-virtualbox.box"
  end

  config.vm.synced_folder ".", "/vagrant", disabled: true

  $NUM_NODE.times do |i|
    n = i+1
    nodename = "node-#{n}"
    config.vm.define nodename do |node|
      node.vm.provision "shell" do |s|
        s.path = "provisioning/provision-node.sh"
        s.args = [nodename]
      end
    end
  end

  # We can not use the vagrant ssh key stuff, because vagrant refuses to integrate sensibly with ansible
  # https://github.com/mitchellh/vagrant/commit/fafaa003916a8f7ca5006f9afa93d5dacf21caa6
  config.ssh.insert_key=false

  config.vm.define "master", primary: true do |config|
    config.vm.provider :libvirt do |v|
      v.memory = $MEMORY
    end
  
    config.vm.provision "shell" do |s|
      s.path = "provisioning/provision-master.sh"
    end
    config.vm.provision "ansible" do |ansible|
      ansible.playbook = "provisioning/etchosts.yml"
      ansible.host_key_checking = false
      ansible.extra_vars = { ansible_ssh_user: 'vagrant' }
      ansible.raw_ssh_args = ['-o ControlMaster=no']
      # Only configure on the last one, it will affect all.  See
      # http://tjheeta.github.io/2014/12/01/ansible-vagrant-multiple-nodes.html
      ansible.limit = "all"
      ansible.groups = $ansible_groups
    end
    config.vm.provision "ansible" do |ansible|
      ansible.playbook = "provisioning/kubernetes-ansible/setup.yml"
      ansible.host_key_checking = false
      ansible.extra_vars = { ansible_ssh_user: 'vagrant', use_node_hostnames: true,
                             kube_service_addresses: $clustersettings['service_addresses'],
                             dns_setup: false }
      ansible.raw_ssh_args = ['-o ControlMaster=no']
      ansible.limit = "all"
      ansible.groups = $ansible_groups
    end
    config.vm.provision "ansible" do |ansible|
      ansible.playbook = "provisioning/kubernetes-ansible/flannel.yml"
      ansible.host_key_checking = false
      ansible.extra_vars = { ansible_ssh_user: 'vagrant' }
      ansible.raw_ssh_args = ['-o ControlMaster=no']
      ansible.limit = "all"
      ansible.groups = $ansible_groups
    end
  end

end
