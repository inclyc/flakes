{ pkgs
, config
, lib
, ...
}:
with lib;
let
  cfg = config.services.clash;
in
{
  options.services.clash = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    package = mkOption {
      type = types.package;
      default = pkgs.clash-meta;
    };
    workingDirectory = mkOption {
      type = types.str;
    };
  };
  config =
    mkIf cfg.enable {
      systemd.services.clash = {

        wantedBy = [ "multi-user.target" ];
        after = [ "network-online.target" ];
        description = "Clash Daemon";

        serviceConfig = {
          Type = "simple";
          WorkingDirectory = "${config.services.clash.workingDirectory}";
          ExecStart = "${lib.getExe cfg.package} -d ${config.services.clash.workingDirectory}";
          Restart = "on-failure";
        };
      };
    };
}
