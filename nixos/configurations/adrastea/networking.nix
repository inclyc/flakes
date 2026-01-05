{ pkgs, config, ... }:
let
  mkTapDev = name: {
    "20-${name}" = {
      netdevConfig = {
        Kind = "tap";
        Name = name;
      };
      tapConfig.User = "lyc";
    };
  };
  mkBrSlave = name: br: {
    "20-${name}" = {
      matchConfig.Name = name;
      bridge = [ br ];
    };
  };
in
{
  networking.dhcpcd.enable = false;
  networking.useDHCP = false;

  systemd.network.enable = true;
  systemd.network.networks = {
    "20-br0" = {
      matchConfig.Name = "br0";
      networkConfig = {
        DHCP = "yes";
        IPv6AcceptRA = true;
      };
    };
    "20-br1" = {
      matchConfig.Name = "br1";
      networkConfig = {
        DHCPServer = true;
        IPMasquerade = "both";
        ConfigureWithoutCarrier = true;
      };
      addresses = [ { Address = "10.157.0.1/24"; } ];
    };
  }
  // mkBrSlave "enp5s0" "br0"
  // mkBrSlave "vmtap0" "br0"
  // mkBrSlave "vmtap1" "br1";

  systemd.network.netdevs = {
    "20-br0" = {
      netdevConfig = {
        Kind = "bridge";
        Name = "br0";
        MACAddress = "BE:CE:CA:F9:E8:D3";
      };
    };
    "20-br1" = {
      netdevConfig = {
        Kind = "bridge";
        Name = "br1";
      };
    };
  }
  // (mkTapDev "vmtap0" // mkTapDev "vmtap1");

  networking.nftables.enable = true;

  systemd.network.wait-online.anyInterface = true;

  inclyc.services.rathole.enable = true;
  sops.secrets."rathole-ssh-token" = { };
  sops.templates."rathole-client.toml".content = ''
    [client]
    remote_addr = "llvmws.inclyc.cn:20155" # The address of the server. The port must be the same with the port in `server.bind_addr`

    [client.transport]
    type = "noise"

    [client.transport.noise]
    remote_public_key = "DVH4EM3P5phh5yzU7cOEDrDvdvahsiSSyeML+okHHx0="

    [client.services.adrastea-ssh]
    token = "${config.sops.placeholder.rathole-ssh-token}" # Must be the same with the server to pass the validation
    local_addr = "0.0.0.0:22" # The address of the service that needs to be forwarded
  '';

  services.tailscale.enable = true;

  inclyc.services.rathole.configFile = config.sops.templates."rathole-client.toml".path;

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

  programs.clash-verge = {
    enable = true;
    tunMode = true;
    serviceMode = true;
    autoStart = true;
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
