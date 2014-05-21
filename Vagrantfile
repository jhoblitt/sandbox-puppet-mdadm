# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.auto_detect = true
    config.cache.scope       = :box
  end

  config.vm.define :centos do |c|
    c.vm.box     = 'centos65'
    c.vm.box_url = 'http://puppet-vagrant-boxes.puppetlabs.com/centos-65-x64-virtualbox-puppet.box'
  end

  file_to_disk1 = './tmp/disk1.vdi'
  file_to_disk2 = './tmp/disk2.vdi'
  config.vm.provider "virtualbox" do | v |
    v.customize ['createhd', '--filename', file_to_disk1, '--size', 1024]
    v.customize ['createhd', '--filename', file_to_disk2, '--size', 1024]
    v.customize ['storageattach', :id, '--storagectl', 'IDE Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', file_to_disk1]
    v.customize ['storageattach', :id, '--storagectl', 'IDE Controller', '--port', 1, '--device', 1, '--type', 'hdd', '--medium', file_to_disk2]
  end

  $script = <<SCRIPT
parted -s /dev/sdb mklabel msdos
parted -s /dev/sdc mklabel msdos
parted -s /dev/sdb mkpart primary 0 -- -1
parted -s /dev/sdc mkpart primary 0 -- -1
mdadm --create /dev/md0 --metadata=0.90 --level=1 --raid-devices=2 /dev/sdb1 /dev/sdc1
mdadm --detail --scan > /etc/mdadm.conf
SCRIPT

  config.vm.provision "shell", inline: $script
  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "manifests"
    puppet.module_path = "modules"
    puppet.manifest_file = "init.pp"
    puppet.options = [
     '--verbose',
     '--report',
     '--show_diff',
     '--pluginsync',
# '--debug',
# '--parser future',
    ]
  end
end
