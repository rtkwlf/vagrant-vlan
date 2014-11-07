require "vagrant"

module VagrantPlugins
  module GuestDebian
    class Plugin < Vagrant.plugin("2")
      guest_capability("debian", "configure_vlans") do
        require_relative "configure_vlans"
        Cap::ConfigureVLANs
      end
    end
  end
end
