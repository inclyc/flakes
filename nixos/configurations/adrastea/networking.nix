{
  pkgs,
  lib,
  config,
  ...
}:
{
  networking.dhcpcd.enable = false;
  networking.useDHCP = false;

  systemd.network.enable = true;

  networking.nftables.enable = true;

  networking.nftables.tables = {
    vnc-filter = {
      family = "inet";
      content = ''
        chain input {
          type filter hook input priority 0; policy accept;

          ip saddr 100.0.0.0/8 tcp dport 5901 accept
          tcp dport 5901 drop
        }
      '';
    };
  };

  systemd.network.wait-online.anyInterface = true;

  services.tailscale.enable = true;

  sops.secrets."ddns/cloudflare" = { };
  services.ddns."cloudflare-adrastea" = {
    ipv6 = "adrastea.inclyc.cn";
    index6 = "default";
    dns = "cloudflare";
    environmentFile = [ config.sops.secrets."ddns/cloudflare".path ];
    onCalendar = "minutely";
  };

  services.ddns."cloudflare-adrastea-6" = {
    ipv6 = "6.adrastea.inclyc.cn";
    index6 = "default";
    dns = "cloudflare";
    environmentFile = [ config.sops.secrets."ddns/cloudflare".path ];
    onCalendar = "minutely";
  };

  sops.secrets."ict-srun-username" = { };
  sops.secrets."ict-srun-password" = { };
  sops.templates."ict-srun-config.json".content = ''
    {
        "server": "http://gw.ict.ac.cn",
        "acid": 1,
        "users": [
            {
                "username": "${config.sops.placeholder.ict-srun-username}",
                "password": "${config.sops.placeholder.ict-srun-password}",
                "if_name": "br0"
            }
        ]
    }
  '';

  sops.secrets."clash/config" = { };

  services.mihomo = {
    enable = true;
    tunMode = true;
    configFile = config.sops.secrets."clash/config".path;
  };

  systemd.services."ict-srun" =
    let
      conf = config.sops.templates."ict-srun-config.json".path;
    in
    {
      description = "ICT SRUN Client Service";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.srun}/bin/srun login -c %d/config.json";
        Restart = "on-failure";
        RestartSec = "10s";
        LoadCredential = "config.json:${conf}";
        DynamicUser = "yes";
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
          "AF_NETLINK"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
      };
    };

  systemd.timers."ict-srun" = {
    description = "ICT SRUN Client Timer";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "hourly";
      Persistent = true;
    };
  };
}
