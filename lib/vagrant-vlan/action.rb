module VagrantPlugins
  module VLAN
    class Action
      def initialize(app, env)
        @app = app
      end

      def call(env)
        vlans = env[:machine].config.vlan.vlans.map do |vlan|
          normalize_config(vlan)
        end

        # Call subsequent middleware steps. We'll do our setup at the
        # end
        @app.call(env)
        
        if !vlans.empty?
          env[:ui].output("Configuring VLANs...")
          env[:machine].guest.capability(:configure_vlans, vlans)
        end
      end

      def normalize_config(config)
        return {
          :type => "dhcp",
          :auto_config => true,
          :ip => nil,
          :netmask => "255.255.255.0"
        }.merge(config || {})
      end
    end
  end
end
