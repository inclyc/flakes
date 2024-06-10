# Declares jump hosts for different network profile.
{ config, lib, ... }:
let
  cfg = config.inclyc.ssh;
  ict-machines = [
    "ict-sw"
    "ict-sw-git"
    "ict-repo"
    "ict-altric"
  ];
  ict-portal = "ict-malcon-pub";
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
    programs.ssh.matchBlocks = lib.genAttrs ict-machines (_: {
      proxyJump = ict-portal;
    });
  };
}
