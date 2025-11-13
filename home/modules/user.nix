{ config, lib, ... }:
let
  cfg = config.inclyc.user;
  inherit (lib) mkOption types;
in
{
  options = {
    inclyc.user = {
      realName = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Real name";
      };
      unixName = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Unix name";
      };
      email = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Email Address";
      };
    };
  };

  config = {
    home.username = lib.mkDefault cfg.unixName;
    home.homeDirectory = lib.mkDefault "/home/${cfg.unixName}";

    programs.git.settings.user = {
      name = lib.mkDefault cfg.realName;
      email = lib.mkDefault cfg.email;
    };
  };
}
