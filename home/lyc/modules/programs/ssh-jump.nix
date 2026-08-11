# Declares jump hosts for different network profile.
{ config, lib, ... }:
let
  cfg = config.inclyc.ssh;
  ict-portals = {
    "ict-altric" = "ict-malcon-pub";
    "ict-146" = "ict-altric";
  };
in
{
  options = {
    inclyc.ssh.ICTProxy = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Add ICT proxy for machines outside of ICT networks";
      example = true;
    };
  };

  config = lib.mkIf cfg.ICTProxy {
    programs.ssh.settings = lib.mapAttrs (host: portal: {
      ProxyJump = portal;
    }) ict-portals;
  };
}
