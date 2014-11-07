require "set"
require "tempfile"

require "vagrant/util/template_renderer"

module VagrantPlugins
  module GuestDebian
    module Cap
      class ConfigureVLANs
        include Vagrant::Util

        # Heavily borrowed from VagrantPlugins::Debian::Cap::ConfigureNetworks.
        def self.configure_vlans(machine, vlans)
          machine.communicate.tap do |comm|
            # Verify the kernel module is installed and loaded.
            if !comm.test("lsmod | grep 8021q")
              comm.sudo("apt-get install vlan")
              comm.sudo("modprobe 8021q")
            end

            # First, remove any previous network modifications
            # from the interface file.
            comm.sudo("sed -e '/^#VAGRANT-VLAN-BEGIN/,/^#VAGRANT-VLAN-END/ d' /etc/network/interfaces > /tmp/vagrant-network-interfaces")
            comm.sudo("su -c 'cat /tmp/vagrant-network-interfaces > /etc/network/interfaces'")
            comm.sudo("rm /tmp/vagrant-network-interfaces")

            # Accumulate the configurations to add to the interfaces file as
            # well as what interfaces we're actually configuring since we use that
            # later.
            interfaces = Set.new
            entries = []
            vlans.each do |vlan|
              vlan[:interface] = "#{vlan[:parent]}.#{vlan[:vlan]}" 
              interfaces.add(vlan[:interface])
              entry = TemplateRenderer.render(File.join(File.dirname(__FILE__), "vlan"),
                                              :options => vlan)

              entries << entry
            end

            # Perform the careful dance necessary to reconfigure
            # the network interfaces
            temp = Tempfile.new("vagrant")
            temp.binmode
            temp.write(entries.join("\n"))
            temp.close

            comm.upload(temp.path, "/tmp/vagrant-network-entry")

            # Bring down all the interfaces we're reconfiguring. By bringing down
            # each specifically, we avoid reconfiguring eth0 (the NAT interface) so
            # SSH never dies.
            interfaces.each do |interface|
              comm.sudo("/sbin/ifdown #{interface} 2> /dev/null")
            end

            comm.sudo("cat /tmp/vagrant-network-entry >> /etc/network/interfaces")
            comm.sudo("rm /tmp/vagrant-network-entry")

            # Bring back up each network interface, reconfigured
            interfaces.each do |interface|
              comm.sudo("/sbin/ifup #{interface}")
            end
          end
        end
      end
    end
  end
end
