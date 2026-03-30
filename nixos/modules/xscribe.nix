{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.xscribe;
in
{
  options.services.xscribe = {
    enable = mkEnableOption "Enable xscribe managed systemd service and timer";

    package = mkOption {
      type = with types; package;
      default = pkgs.xscribe;
      description = "Package used for xscribe service.";
    };

    environmentFile = mkOption {
      type = types.str;
      default = "/etc/xscribe/env";
      description = "Systemd EnvironmentFile path for xscribe service.";
    };

    timer = {
      enable = mkEnableOption "xscribe timer";

      onCalendar = mkOption {
        type = types.str;
        default = "*:0/30";
        description = "OnCalendar schedule for xscribe timer.";
      };

      randomizedDelaySec = mkOption {
        type = types.str;
        default = "1m";
        description = "RandomizedDelaySec for xscribe timer.";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.xscribe = {
      description = "Xscribe service";
      after = [
        "network-online.target"
        "mihomo.service"
      ];
      wants = [
        "mihomo.service"
        "network-online.target"
      ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${cfg.package}/bin/xscribe";
        EnvironmentFile = cfg.environmentFile;

        Restart = "on-failure";
        RestartSec = "5s";

        DynamicUser = true;
        RuntimeDirectory = "xscribe";
        ConfigurationDirectory = "xscribe";

        CapabilityBoundingSet = "";
        DeviceAllow = [ "" ];
        DevicePolicy = "closed";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectClock = "yes";
        ProtectControlGroups = "yes";
        ProtectHome = true;
        ProtectHostname = "yes";
        ProtectKernelLogs = "yes";
        ProtectKernelModules = "yes";
        ProtectKernelTunables = "yes";
        ProtectProc = "invisible";
        ProtectSystem = "strict";
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

    systemd.timers.xscribe = mkIf cfg.timer.enable {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.timer.onCalendar;
        RandomizedDelaySec = cfg.timer.randomizedDelaySec;
        Persistent = true;
      };
    };
  };
}
