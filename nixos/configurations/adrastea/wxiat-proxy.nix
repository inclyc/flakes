{ config, ... }:
{
  sops.secrets."wxiat-proxy-env" = { };

  virtualisation.oci-containers.containers.wxiat-proxy = {
    image = "hagb/docker-easyconnect:cli";
    autoStart = true;
    ports = [
      "127.0.0.1:1080:1080"
    ];
    devices = [
      "/dev/net/tun"
    ];
    capabilities = {
      NET_ADMIN = true;
    };
    environmentFiles = [
      config.sops.secrets."wxiat-proxy-env".path
    ];
    environment = {
      EC_VER = "7.6.7";
    };
  };
}
