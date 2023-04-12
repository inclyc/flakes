{ config, lib, ... }:
with lib;
let
  cfg = config.inclyc.user;
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

    programs.git = {
      userName = lib.mkDefault cfg.realName;
      userEmail = lib.mkDefault cfg.email;
    };
  };
}
