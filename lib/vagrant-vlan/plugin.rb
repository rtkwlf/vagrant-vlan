require "vagrant"

require_relative "debian/guest"

module VagrantPlugins
  module VLAN
    class Plugin < Vagrant.plugin("2")
      name "VLAN configuration"
      description "Configure VLANs"

      action_hook(:configure_vlans) do |hook|
        require_relative "action"
        # We're injecting ourselves before the Vagrant standard network
        # configuration step because we (as well as the standard network
        # configuration middleware) do the actual network configuration on the
        # way up the middleware stack. Therefore, this ensures that we will
        # configure the vlans after the rest of the interfaces.

        # Hook in before VirtualBox provider
        hook.before(VagrantPlugins::ProviderVirtualBox::Action::Network,
                    Action)

        if Vagrant.has_plugin?("vagrant-lxc")
          require "vagrant-lxc/action"
          # Hook in before LXC provider if we have one
          hook.before(Vagrant::LXC::Action::PrivateNetworks, Action)
        end
      end

      config "vlan" do
        require_relative "config"
        VagrantPlugins::VLAN::Config
      end
    end
  end
end
