{ pkgs, ... }:
{
  systemd.slices.system.sliceConfig.MemoryMin = "960M";

  systemd.services = {
    "systemd-networkd".serviceConfig = {
      MemoryMin = "64M";
      OOMScoreAdjust = -500;
    };
    "systemd-resolved".serviceConfig = {
      MemoryMin = "64M";
      OOMScoreAdjust = -500;
    };
    "sshd".serviceConfig = {
      MemoryMin = "64M";
      OOMScoreAdjust = -500;
    };
    "ict-srun".serviceConfig = {
      MemoryMin = "64M";
      OOMScoreAdjust = -500;
    };
    "tailscaled".serviceConfig = {
      MemoryMin = "192M";
      OOMScoreAdjust = -500;
    };
    "mihomo".serviceConfig = {
      MemoryMin = "512M";
      OOMScoreAdjust = -500;
    };

    "br0-recovery" = {
      description = "Recover br0 when its DHCPv4 route is unavailable";
      after = [ "systemd-networkd.service" ];
      wants = [ "systemd-networkd.service" ];
      path = [ pkgs.systemd ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.python3}/bin/python3 ${./br0_recovery.py}";
        RuntimeDirectory = "br0-recovery";
        RuntimeDirectoryPreserve = "yes";
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "strict";
      };
    };
  };

  systemd.timers."br0-recovery" = {
    description = "Check the br0 DHCPv4 route";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "2min";
      OnUnitActiveSec = "1min";
      Persistent = true;
      AccuracySec = "15s";
      Unit = "br0-recovery.service";
    };
  };
}
