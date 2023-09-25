{ lib, ... }:
let
  vtap = {
    virtual = true;
    virtualOwner = "lyc";
  };
in
{
  networking = {
    networkmanager.enable = lib.mkForce false;
    useDHCP = false;

    interfaces.enp5s0.useDHCP = false;

    # External bridge, connect to the internet directly
    interfaces.brx0.useDHCP = true;
    bridges.brx0.interfaces = [ "enp5s0" "vmtap0" ];

    # NAT network for VMs
    nat = {
      enable = true;
      externalInterface = "Meta";
      internalIPs = [ "10.157.3.0/24" ];
    };
    bridges.bri0.interfaces = [ "vmtap1" ];
    interfaces.bri0 = {
      ipv4.addresses = [{ address = "10.157.3.1"; prefixLength = 24; }];
    };

    # Pre-allocated interfaces for VM, create them
    interfaces.vmtap0 = vtap;
    interfaces.vmtap1 = vtap;
  };
}
