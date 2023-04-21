{ config
, lib
, pkgs
, ...
}:
with lib;
let
  cfg = config.services.ddns;
  ddnsOptions = {
    options = {
      ipv4 = mkOption {
        type = with types; nullOr str;
        default = null;
      };
      ipv6 = mkOption {
        type = with types; nullOr str;
        default = null;
      };
      index4 = mkOption {
        type = with types; nullOr str;
        default = null;
      };
      index6 = mkOption {
        type = with types; nullOr str;
        default = null;
      };
      ttl = mkOption {
        type = with types; nullOr int;
        default = null;
      };
      proxy = mkOption {
        type = with types; nullOr str;
        default = null;
      };
      dns = mkOption {
        type = with types; nullOr str;
        default = null;
      };
      package = mkOption {
        type = with types; package;
        default = pkgs.ddns;
      };
      extraPath = mkOption {
        type = with types; listOf package;
        default = [ ];
      };
      environmentFile = mkOption {
        type = with types; listOf str;
        default = [ ];
      };
      onCalendar = mkOption {
        type = with types; nullOr str;
        default = null;
      };
    };
  };
  mkService = name: ddns: {
    path = [ ddns.package ] ++ ddns.extraPath;
    environment = mapAttrs'
      (name: value: nameValuePair
        ("DDNS_${toUpper name}")
        value)
      (filterAttrs
        (n: v: (builtins.typeOf v) == "string" && n != "onCalendar")
        ddns);
    serviceConfig = {
      ExecStart = "${ddns.package}/bin/ddns";
      EnvironmentFile = ddns.environmentFile;
      DynamicUser = true;
    };
  };
  mkTimer = name: ddns: mkIf (ddns.onCalendar != null) {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = ddns.onCalendar;
      Persistent = true;
    };
  };
in
{
  options.services.ddns = mkOption {
    default = { };
    type = types.attrsOf (types.submodule ddnsOptions);
  };
  config = lib.mkIf (cfg != { }) (lib.mkMerge [
    {
      systemd.services = mapAttrs' (n: v: nameValuePair "ddns-${n}" (mkService n v)) cfg;
      systemd.timers = mapAttrs' (n: v: nameValuePair "ddns-${n}" (mkTimer n v)) cfg;
    }
  ]);
}
