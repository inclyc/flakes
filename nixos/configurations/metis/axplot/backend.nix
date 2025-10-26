{
  pkgs,
  config,
  lib,
  ...
}:
let
  nameBase = "axplot-backend";
  profiles = [
    "production"
    "testing"
  ];
in
{
  sops.secrets."${nameBase}" = { };
  systemd.services = lib.genAttrs' profiles (
    profile:
    let
      port = builtins.readFile ./${profile}/backend.port;
      axplot = pkgs.stdenvNoCC.mkDerivation {
        name = nameBase;
        src = pkgs.requireFile {
          name = nameBase;
          message = "Executable to ${nameBase}";
          sha256 = builtins.readFile ./${profile}/backend.sha256;
        };

        dontUnpack = true;

        installPhase = ''
          runHook preInstall
          mkdir -p $out/bin
          cp $src $out/bin/${nameBase}
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

        meta.mainProgram = nameBase;
      };
    in
    rec {
      name = if profile == "production" then nameBase else "${nameBase}-${profile}";
      value = {
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        description = "Backend for axplot";
        environment = {
          RUST_LOG = "info";
          DATABASE_URL = "sqlite:///var/lib/${name}/db.sqlite";
          OPENROUTER_BASE_URL = "https://api.deepseek.com/chat/completions";
          MODEL = "deepseek-chat";
          BIND_ADDRESS = "127.0.0.1:${port}";
        };
        serviceConfig = {
          DynamicUser = "yes";
          EnvironmentFile = [ config.sops.secrets."${nameBase}".path ];
          ExecStart = lib.getExe axplot;
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
    }
  );
}
