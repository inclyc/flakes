{ config, pkgs, ... }:

{
  sops.secrets."xscribe/env" = {
    owner = "root";
    mode = "0440";
  };

  systemd.services.xscribe = {
    description = "Xscribe service";
    after = [
      "network.target"
      "sops-nix.service"
    ];
    wants = [ "sops-nix.service" ];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.xscribe}/bin/xscribe";
      EnvironmentFile = config.sops.secrets."xscribe/env".path;

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

  systemd.timers.xscribe = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*:0/30";
      RandomizedDelaySec = "1m";
      Persistent = true;
    };
  };
}
