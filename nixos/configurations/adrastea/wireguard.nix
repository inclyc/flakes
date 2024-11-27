{ config, pkgs, ... }:
{
  sops.secrets."wireguard/privkeys/adrastea" = {
    owner = config.users.users.systemd-network.name;
  };

  environment.systemPackages = with pkgs; [ wireguard-tools ];

  systemd.network.netdevs = {
    "10-wg0" = {
      netdevConfig = {
        Kind = "wireguard";
        Name = "wg0";
        MTUBytes = "1300";
      };
      wireguardConfig = {
        PrivateKeyFile = config.sops.secrets."wireguard/privkeys/adrastea".path;
        ListenPort = 9918;
      };
      wireguardPeers = [
        {
          PublicKey = "CMb1V4DaIsYRY5dNxZSzQZD6Xnd5/DNyDPJoRtosfgs=";
          AllowedIPs = [ "10.231.0.1/16" ];
          Endpoint = "llvmws.inclyc.cn:20125";
          PersistentKeepalive = 25;
        }
        {
          PublicKey = "GcR4Wx7JUJOCO5Rs+gs0S4xbnC4NqU4ltCsSowjwEyg=";
          AllowedIPs = [ "0.0.0.0/0" ];
          Endpoint = "t.inclyc.cn:45229";
          PersistentKeepalive = 25;
        }
      ];
    };
  };

  systemd.network.networks = {
    wg0 = {
      matchConfig.Name = "wg0";
      address = [ "10.164.2.8/16" ];
      DHCP = "no";
      networkConfig = {
        IPv6AcceptRA = false;
      };
    };
  };
}
