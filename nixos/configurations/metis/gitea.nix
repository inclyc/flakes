{ config, pkgs, ... }:
let
  domain = "git.inclyc.cn";
  url = "https://${domain}";
in
{
  sops.secrets = {
    "gitea/runners/simd" = { };
    "gitea/runners/fuse-feature" = { };
  };

  services = {
    gitea-actions-runner.instances = {
      "simd" = {
        inherit url;
        enable = true;
        name = "simd";
        tokenFile = config.sops.secrets."gitea/runners/simd".path;
        labels = [
          "native:host"
        ];
        hostPackages = with pkgs; [
          ninja
          gcc9
          bash
          coreutils
          diffutils
          curl
          gawk
          gitMinimal
          gnused
          nodejs
          wget
          cmake
          python3
        ];
      };
      "fuse-feature" = {
        inherit url;
        enable = true;
        name = "fuse-feature";
        tokenFile = config.sops.secrets."gitea/runners/fuse-feature".path;
        labels = [
          "native:host"
        ];
        hostPackages = with pkgs; [
          coreutils
          curl
          gnused
          nodejs
          wget
          cmake

          gitMinimal

          # Python environment
          python3
          poetry

          (buildFHSEnv {
            name = "many-linux-fhs";
            targetPkgs =
              pkgs:
              (with pkgs; [
                stdenv.cc
                perl
                python3
                glib
                zlib
                git
                openssh
              ]);
            runScript = lib.getExe python3;
          })
        ];
      };
    };
    caddy = {
      enable = true;
      virtualHosts = {
        "git.inclyc.cn" = {
          extraConfig = "
          reverse_proxy unix/${config.services.gitea.settings.server.HTTP_ADDR}
        ";
        };
      };
    };
    gitea = {
      enable = true;
      settings = {
        server = {
          PROTOCOL = "http+unix";
          DOMAIN = domain;
          ROOT_URL = url;
          SSH_PORT = 20122;
        };
      };
    };
  };
}
