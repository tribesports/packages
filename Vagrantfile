# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "10.04-32"
  config.vm.box_url = "http://files.vagrantup.com/lucid32.box"

  config.vm.share_folder "vagrant_share", "/vagrant_share", "."

  config.vm.provision :shell, :inline => "/vagrant_share/server_init.sh"

end
