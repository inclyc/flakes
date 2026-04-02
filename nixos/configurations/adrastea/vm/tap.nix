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
        IPv6Forwarding = true;
      };
      ipv6AcceptRAConfig = {
        RouteMetric = 2048;
      };
    };
    "20-br1" = {
      matchConfig.Name = "br1";
      networkConfig = {
        DHCPServer = true;
        IPMasquerade = "ipv4";
        ConfigureWithoutCarrier = true;
        IPv6SendRA = true;
        IPv6Forwarding = true;
      };
      ipv6Prefixes = [
        { Prefix = "2400:dd01:1034:1112::/64"; }
      ];
      addresses = [
        { Address = "10.157.0.1/24"; }
        { Address = "2400:dd01:1034:1112::1/64"; }
      ];
    };
  }
  // physSlaves
  // allTapSlaves;

  services.ndppd = {
    enable = true;
    proxies.br0 = {
      rules = {
        "2400:dd01:1034:1112::/64" = {
          method = "static";
        };
      };
    };
  };

  boot.kernel.sysctl = {
    "net.ipv6.conf.all.forwarding" = 1;
    "net.ipv6.conf.br0.proxy_ndp" = 1;
    "net.ipv4.ip_forward" = 1;
  };

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
