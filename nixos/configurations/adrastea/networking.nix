{ lib, config, ... }:
let
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
in
{
  networking.dhcpcd.enable = false;

  systemd.network.enable = true;
  systemd.network.networks = {
    "20-br0" = {
      matchConfig.Name = "br0";
      networkConfig = {
        DHCP = "no";
        Address = "10.12.150.59/24";
        Gateway = "10.12.150.254";
        DNS = "159.226.39.1";
      };
    };
    "20-br1" = {
      matchConfig.Name = "br1";
      networkConfig = {
        DHCPServer = true;
        IPMasquerade = "both";
        ConfigureWithoutCarrier = true;
      };
      addresses = [
        { addressConfig.Address = "10.157.0.1/24"; }
      ];
    };
  } // mkBrSlave "enp5s0" "br0"
  // mkBrSlave "vmtap0" "br0"
  // mkBrSlave "vmtap1" "br1";

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
  } // (mkTapDev "vmtap0" // mkTapDev "vmtap1");

  networking.nftables.enable = true;

  systemd.network.wait-online.anyInterface = true;

  services.dae.enable = true;

  services.clash = {
    enable = true;
    configPath = config.sops.templates."clash-config.yaml".path;
  };
}
