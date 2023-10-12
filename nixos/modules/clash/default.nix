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
  };
  config =
    mkIf cfg.enable {

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
        after = [ "network-online.target" ];
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
    };
}
