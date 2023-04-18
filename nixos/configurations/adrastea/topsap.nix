{ config, ... }:

let
  backend = "podman";
in
{
  sops.secrets.swyjs-credential = { };
  virtualisation.oci-containers.backend = backend;
  virtualisation.oci-containers.containers.topsap = {
    image = "ghcr.io/inclyc/containerized-topsap:main";
    ports = [ "1082:1080" ];
    extraOptions = [ "--device" "/dev/net/tun" "--privileged" "--cap-add" "NET_ADMIN" ];
    environmentFiles = [ config.sops.secrets.swyjs-credential.path ];
  };
}
