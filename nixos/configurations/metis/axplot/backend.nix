{
  pkgs,
  config,
  lib,
  ...
}:
let
  name = "axplot-backend";
  axplot = pkgs.stdenvNoCC.mkDerivation {
    inherit name;
    src = pkgs.requireFile {
      inherit name;
      message = "Executable to ${name}";
      sha256 = builtins.readFile ./axplot-backend.sha256;
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
in
{
  sops.secrets."${name}" = { };
  systemd.services = {
    "${name}" = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      description = "Backend for axplot";
      environment = {
        RUST_LOG = "info";
        DATABASE_URL = "sqlite:///var/lib/${name}/db.sqlite";
        OPENROUTER_BASE_URL = "https://api.deepseek.com/chat/completions";
        MODEL = "deepseek-chat";
      };
      serviceConfig = {
        DynamicUser = "yes";
        EnvironmentFile = [ config.sops.secrets."${name}".path ];
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
  };
}
