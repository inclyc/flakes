{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption types mkIf;
  cfg = config.inclyc.services.rathole;
in
{
  options.inclyc.services.rathole = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    package = mkOption {
      type = types.package;
      default = pkgs.rathole;
    };
    configFile = mkOption { type = types.path; };

    name = mkOption {
      type = types.str;
      example = "rathole";
      default = "rathole";
    };
  };
  config =
    let
      inherit (cfg) configFile name;
    in
    mkIf cfg.enable {
      systemd.services."${name}" = {
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        description = "rathole (userspace network tunnels)";

        serviceConfig = {
          Type = "simple";
          DynamicUser = "yes";
          ExecStart = "${lib.getExe cfg.package} %d/config.toml";
          LoadCredential = "config.toml:${configFile}";
          LimitNOFILE = 1048576;
          RestartSec = "5s";
          Restart = "on-failure";
          CapabilityBoundingSet = [ "" ];
          DeviceAllow = [ "" ];
          PrivateDevices = true;
          PrivateTmp = true;
          PrivateUsers = true;
          ProtectSystem = "strict";
          ProtectHome = "yes";
          ProtectHostname = "yes";
          ProtectClock = "yes";
          ProtectKernelTunables = "yes";
          ProtectKernelModules = "yes";
          ProtectKernelLogs = "yes";
          ProtectControlGroups = "yes";
          ProtectProc = "invisible";
          LockPersonality = "yes";
          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
          ];
          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          SystemCallArchitectures = "native";
        };
      };
    };
}
