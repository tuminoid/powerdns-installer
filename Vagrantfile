# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.define :precise64 do |precise64|
    precise64.vm.box = "precise64"
    precise64.vm.box_url = "http://files.vagrantup.com/precise64.box"
    precise64.vm.provision :shell, :path => "install.sh"
    precise64.vm.network :forwarded_port, guest: 80, host: 40080
  end

  config.vm.provider "vmware_fusion" do |v, override|
    override.vm.box = "precise64_fusion"
    override.vm.box_url = "http://files.vagrantup.com/precise64_vmware.box"
  end
end
