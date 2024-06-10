{ config, pkgs, ... }:
{
  sops.secrets."wireguard/privkeys/aplaz" = {
    owner = config.users.users.systemd-network.name;
  };

  environment.systemPackages = with pkgs; [ wireguard-tools ];

  systemd.network.enable = true;

  systemd.network.netdevs = {
    "10-wg0" = {
      netdevConfig = {
        Kind = "wireguard";
        Name = "wg0";
        MTUBytes = "1300";
      };
      wireguardConfig = {
        PrivateKeyFile = config.sops.secrets."wireguard/privkeys/aplaz".path;
        ListenPort = 9918;
      };
      wireguardPeers = [
        {
          wireguardPeerConfig = {
            PublicKey = "CMb1V4DaIsYRY5dNxZSzQZD6Xnd5/DNyDPJoRtosfgs=";
            AllowedIPs = [ "10.231.0.1/16" ];
            Endpoint = "llvmws.lyc.dev:20125";
            PersistentKeepalive = 25;
          };
        }
      ];
    };
  };

  systemd.network.networks = {
    wg0 = {
      matchConfig.Name = "wg0";
      address = [ "10.231.0.3/16" ];
      DHCP = "no";
      networkConfig = {
        IPv6AcceptRA = false;
      };
    };
  };
}
