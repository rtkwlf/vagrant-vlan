# Vagrant VLAN Plugin

A plugin to configure a VLAN within a guest.

The implementation relies on Vagrant's guest capabilities. Currently, the plugin
supports only Debian-derived guests and in particular has been tested only on
Ubuntu. However, contributions to add support for other guests are more than
welcome.

## Installation

Use `vagrant plugin install`:

    $ vagrant plugin install vagrant-vlan

## Usage

Setting up a VLAN is accomplished using the `config.vlan.add`
gestures. The gesture takes similar parameters to `config.vm.network`, with
some exceptions. Valid parameters are as follows:

* `vlan`
   The VLAN identifier. An integer in the range [1, 4094].
* `parent`
  The parent (or physical) interface to which the VLAN interface should attach.
* `type`
  Method of IP assignment. Valid values are "dhcp" and "static".
* `ip`
  Required if `type` is "static". The IP address to be assigned to the interface.
* `netmask`
  Required if `type` is "static". The netmask to use for the interface.

The name of the interface will be constructed automatically using the format
`parent`.`vlan`.

Note that the VLAN plugin runs immediately after Vagrant network configuration,
so `parent` can include interfaces configured using `config.vm.network`.

### Example

Create VLAN 5 on interface `eth0`, and assign it the static IP 10.0.1.2/24.
The name of the VLAN interface will be `eth0.5`.

```ruby
config.vlan.add vlan: 5, parent: "eth0",
                type: "static", ip: "10.0.1.2", netmask: "255.255.255.0"
```

The `config` object in the example is what was passed by Vagrant to the
`config.vm.define` block.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
