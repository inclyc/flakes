{ pkgs, ... }:

{
  services.dae = {
    package = pkgs.dae;
    disableTxChecksumIpGeneric = false;
    config = builtins.readFile ./config.dae;
    assets = with pkgs; [
      v2ray-geoip
      v2ray-domain-list-community
    ];
  };
}
