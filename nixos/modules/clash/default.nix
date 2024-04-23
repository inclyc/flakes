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
    enable = mkEnableOption "clash service";
    package = mkOption {
      type = types.package;
      default = pkgs.clash-meta;
    };
    workingDirectory = mkOption {
      type = types.str;
      default = "/tmp";
    };
    configDirectory = mkOption {
      type = types.str;
      default = "/tmp";
    };
    configPath = mkOption {
      type = types.path;
    };
    rule = {
      enable = mkEnableOption "clash rule generation";
    };
  };
  config = lib.mkMerge [
    (mkIf cfg.enable {
      systemd.services.clash = {
        wantedBy = [ "multi-user.target" ];
        after = [ "systemd-networkd-wait-online.service" ];
        description = "Clash Daemon";
        serviceConfig = {
          Type = "simple";
          DynamicUser = "yes";
          LoadCredential = "config.yaml:${cfg.configPath}";
          WorkingDirectory = "${cfg.workingDirectory}";
          ExecStartPre = "${pkgs.coreutils}/bin/ln -s ${pkgs.clash-geoip}/etc/clash/Country.mmdb ${cfg.configDirectory}";
          ExecStart = "${lib.getExe cfg.package}"
            + " -d ${cfg.configDirectory}"
            + " -f %d/config.yaml";
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
          RestrictAddressFamilies = [ "AF_INET" "AF_INET6" ];
          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          SystemCallArchitectures = "native";
        };
      };
    })
    (mkIf cfg.rule.enable (
      let
        generate_204 = "http://www.gstatic.com/generate_204";
        providers = [ "dler" "mielink" "bywave" ];
        proxyProviders = lib.genAttrs providers (name: {
          type = "http";
          path = "./${name}.yaml";
          url = "${config.sops.placeholder."clash-provider/${name}"}";
          interval = 3600;
          health-check = {
            enable = true;
            url = generate_204;
            interval = 300;
          };
        });
        proxyGroups = [
          {
            name = "Proxy";
            type = "select";
            use = providers;
            proxies = [
              "Auto"
              "DIRECT"
            ];
          }
          {
            name = "Auto";
            type = "url-test";
            use = providers;
            proxies = [ "DIRECT" ];
            url = generate_204;
            interval = "3600";
          }
        ] ++ builtins.fromJSON (builtins.readFile ./proxy-groups.json);
      in
      {
        services.clash.configPath = lib.mkDefault config.sops.templates."clash-config.yaml".path;
        sops.secrets = lib.attrsets.mergeAttrsList (map
          (name: {
            "clash-provider/${name}" = { };
          })
          providers);
        sops.templates."clash-config.yaml".content = builtins.readFile ./rule.yaml + ''
          proxy-groups: ${builtins.toJSON proxyGroups}
          proxy-providers: ${builtins.toJSON proxyProviders}
        '';
      }
    ))
  ];
}
