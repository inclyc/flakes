{ pkgs
, config
, lib
, ...
}:

let
  cfg = config.inclyc.tailscale;
in
{
  options.inclyc.tailscale.enable = lib.mkEnableOption "tailscale";
  config = lib.mkIf cfg.enable {
    services.tailscale.enable = true;
    environment.systemPackages = [ pkgs.tailscale ];
  };
}


