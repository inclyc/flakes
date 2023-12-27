{ pkgs
, config
, lib
, ...
}:
with lib;
let
  cfg = config.services.clash;
  defaultUser = "clash";
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
    user = mkOption {
      default = defaultUser;
      example = "john";
      type = types.str;
    };

    group = mkOption {
      default = defaultUser;
      example = "users";
      type = types.str;
    };
    rule = {
      enable = mkEnableOption "clash rule generation";
      enableTUN = mkEnableOption "TUN interface";
    };
  };
  config = lib.mkMerge [
    (mkIf cfg.enable {
      users.users = optionalAttrs (cfg.user == defaultUser) {
        ${defaultUser} =
          {
            description = "clash user";
            group = defaultUser;
            uid = config.ids.uids.znc;
            isSystemUser = true;
          };
      };

      users.groups = optionalAttrs (cfg.user == defaultUser) {
        ${defaultUser} =
          {
            gid = config.ids.gids.znc;
            members = [ defaultUser ];
          };
      };

      systemd.services.clash = {

        wantedBy = [ "multi-user.target" ];
        after = [ "systemd-networkd-wait-online.service" ];
        description = "Clash Daemon";

        serviceConfig = rec {
          Type = "simple";
          User = cfg.user;
          Group = cfg.group;
          PrivateTmp = true;
          WorkingDirectory = "${cfg.workingDirectory}";
          ExecStartPre = "${pkgs.coreutils}/bin/ln -s ${pkgs.clash-geoip}/etc/clash/Country.mmdb ${cfg.configDirectory}";
          ExecStart = "${lib.getExe cfg.package}"
            + " -d ${cfg.configDirectory}"
            + " -f ${cfg.configPath}";
          Restart = "on-failure";
          CapabilityBoundingSet = [ "CAP_NET_ADMIN" "CAP_NET_RAW" "CAP_NET_BIND_SERVICE" ];
          AmbientCapabilities = CapabilityBoundingSet;
        };
      };
    })
    (mkIf cfg.rule.enable (
      let
        providers = [ "dler" "mielink" "bywave" ];
        proxyProviders = lib.genAttrs providers (name: {
          type = "http";
          path = "./${name}.yaml";
          url = "${config.sops.placeholder."clash-provider/${name}"}";
          interval = 3600;
          health-check = {
            enable = true;
            url = "http://www.gstatic.com/generate_204";
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
            url = "http://cp.cloudflare.com/generate_204";
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
        '' + (lib.optionalString cfg.rule.enableTUN ''
          tun:
              enable: true
              stack: system
              auto-route: true
              auto-detect-interface: true
        '');

        sops.templates."clash-config.yaml".owner = cfg.user;
        sops.templates."clash-config.yaml".group = cfg.group;
      }
    ))
  ];
}
