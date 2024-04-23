{ config, pkgs, ... }:
{
  sops.secrets."wireguard/privkeys/metis" = {
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
        PrivateKeyFile = config.sops.secrets."wireguard/privkeys/metis".path;
        ListenPort = 20125;
      };
      wireguardPeers = [
        {
          wireguardPeerConfig = {
            PublicKey = "bc1g46/rPzwG7x9amS+YdVuISU1Xl2kx7Hxs5W3zTQw=";
            AllowedIPs = [ "10.231.0.2" ];
          };
        }
        {
          wireguardPeerConfig = {
            PublicKey = "o0Z8h2XycBqgfomicsgoSDKLbqjRt6Fm3uBMavWVPAM=";
            AllowedIPs = [ "10.231.0.3" ];
          };
        }
      ];
    };
  };

  systemd.network.networks.wg0 = {
    matchConfig.Name = "wg0";
    address = [ "10.231.0.1/16" ];
  };
}
