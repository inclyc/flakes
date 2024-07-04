{ config, ... }:
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
  networking.useDHCP = false;

  services.dante.enable = true;
  services.dante.config = ''
        internal: 0.0.0.0 port = 20179
        external: br0
        clientmethod: none
        socksmethod: none
          client pass {
    	    from: 0.0.0.0/0 to: 0.0.0.0/0
    	    log: error connect disconnect
        }
        socks pass {
    	    from: 0.0.0.0/0 to: 10.3.2.104/32
    	    command: bind connect udpassociate bindreply udpreply
    	    log: error connect disconnect iooperation
        }
        socks pass {
    	    from: 0.0.0.0/0 to: 10.3.2.130/32
    	    command: bind connect udpassociate bindreply udpreply
    	    log: error connect disconnect iooperation
        }
        socks pass {
    	    from: 0.0.0.0/0 to: 10.208.130.239/32
    	    command: bind connect udpassociate bindreply udpreply
    	    log: error connect disconnect iooperation
        }
  '';

  systemd.network.enable = true;
  systemd.network.networks = {
    "20-br0" = {
      matchConfig.Name = "br0";
      networkConfig = {
        DHCP = "yes";
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
  } // mkBrSlave "enp5s0" "br0" // mkBrSlave "vmtap0" "br0" // mkBrSlave "vmtap1" "br1";

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
    rule.enable = true;
  };

  services.rathole.enable = true;
  sops.secrets."rathole-ssh-token" = { };
  sops.templates."rathole-client.toml".content = ''
    [client]
    remote_addr = "llvmws.lyc.dev:20155" # The address of the server. The port must be the same with the port in `server.bind_addr`

    [client.transport]
    type = "noise"

    [client.transport.noise]
    remote_public_key = "DVH4EM3P5phh5yzU7cOEDrDvdvahsiSSyeML+okHHx0="

    [client.services.adrastea-ssh]
    token = "${config.sops.placeholder.rathole-ssh-token}" # Must be the same with the server to pass the validation
    local_addr = "0.0.0.0:22" # The address of the service that needs to be forwarded
  '';

  services.rathole.configFile = config.sops.templates."rathole-client.toml".path;
}
