{
  lib,
  ...
}:
let
  taps = {
    "vmtap0" = "br0";
    "vmtap1" = "br1";
    "vmtap2" = "br0";
    "vmtap3" = "br1";
  };
  mkTapDev = name: {
    "20-${name}" = {
      netdevConfig = {
        Kind = "tap";
        Name = name;
      };
      tapConfig.User = "lyc";
    };
  };
  mkBrSlave = name: br: {
    "20-${name}" = {
      matchConfig.Name = name;
      bridge = [ br ];
    };
  };

  allTapNetdevs = lib.mergeAttrsList (lib.mapAttrsToList (name: _: mkTapDev name) taps);
  allTapSlaves = lib.mergeAttrsList (lib.mapAttrsToList (name: br: mkBrSlave name br) taps);

  physSlaves = mkBrSlave "enp5s0" "br0";
in
{
  systemd.network.networks = {
    "20-br0" = {
      matchConfig.Name = "br0";
      networkConfig = {
        DHCP = "yes";
        IPv6AcceptRA = true;
      };
    };
    "20-br1" = {
      matchConfig.Name = "br1";
      networkConfig = {
        DHCPServer = true;
        IPMasquerade = "both";
        ConfigureWithoutCarrier = true;
      };
      addresses = [ { Address = "10.157.0.1/24"; } ];
    };
  }
  // physSlaves
  // allTapSlaves;

  systemd.network.netdevs = {
    "20-br0" = {
      netdevConfig = {
        Kind = "bridge";
        Name = "br0";
        MACAddress = "BE:CE:CA:F9:E8:D3";
      };
    };
    "20-br1" = {
      netdevConfig = {
        Kind = "bridge";
        Name = "br1";
      };
    };
  }
  // allTapNetdevs;
}
