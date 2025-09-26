{
  pkgs,
  config,
  lib,
  ...
}:
let
  name = "huiyan-backend";
  huiyan = pkgs.stdenvNoCC.mkDerivation {
    inherit name;
    src = pkgs.requireFile {
      inherit name;
      message = "Executable to ${name}";
      sha256 = "03vhmhw03wv1wjv439cdfk40rn0i71s6ahg1qzmy8w4b2mx5jbgp";
    };

    dontUnpack = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      cp $src $out/bin/${name}
      chmod +x -R $out/bin/
      runHook postInstall
    '';

    buildInputs = with pkgs; [
      openssl
      stdenv.cc.cc.lib
    ];

    nativeBuildInputs = with pkgs; [
      autoPatchelfHook
    ];

    meta.mainProgram = name;
  };

  pyodide = pkgs.stdenv.mkDerivation rec {
    pname = "pyodide";
    version = "0.27.7";
    src = pkgs.fetchurl {
      url = "https://github.com/pyodide/pyodide/releases/download/${version}/pyodide-${version}.tar.bz2";
      sha256 = "0md7dr1n1mvdq5xjcib5b4g00xnzbflxm9z21zm100biqi7pzp88";
    };

    installPhase = ''
      mkdir -p $out
      cp -a . $out/
    '';

    dontFixup = true;
  };
in
{
  sops.secrets."${name}" = { };

  services.caddy = {
    enable = true;
    virtualHosts = {
      "huiyan.inclyc.cn" = {
        extraConfig = ''
          root * /var/lib/caddy/huiyan-frontend
          file_server
          handle_path /huiyan/* {
            reverse_proxy 127.0.0.1:54289
          }
          handle_path /pyodide/*  {
            root * ${pyodide}
            file_server
          }
        '';
      };
    };
  };

  systemd.services = {
    "${name}" = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      description = "Backend for huiyan";
      environment = {
        RUST_LOG = "info";
        DATABASE_URL = "sqlite:///var/lib/${name}/db.sqlite";
      };
      serviceConfig = {
        DynamicUser = "yes";
        EnvironmentFile = [ config.sops.secrets."${name}".path ];
        ExecStart = lib.getExe huiyan;
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
        StateDirectory = name;
      };
    };
  };
}
