require "vagrant"

module VagrantPlugins
  module VLAN
    class Config < Vagrant.plugin(2, :config)
      def initialize
        @__vlans = []
      end

      def add(**options)
        @__vlans << options.dup
      end

      def vlans
        @__vlans
      end

      def merge(other)
        super.tap do |result|
          result.instance_variable_set(:@__vlans, @__vlans + other.vlans)
        end
      end

      def validate(machine)
        errors = _detected_errors || []

        vlans.each do |vlan|
          errors << "The VLAN interface name will be constructed automatically." if vlan.include? :interface
          errors << "A VLAN id must be specified." if !vlan.include? :vlan
          errors << "The VLAN id must be an integer in the range [1, 4094]." if !vlan[:vlan].is_a?(Integer) || !vlan[:vlan].between?(1, 4094)
          errors << "A parent interface must be specified." if !vlan.include? :parent
        end

        { "vlan" => errors }
      end
    end
  end
end
