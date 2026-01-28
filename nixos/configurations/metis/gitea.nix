{ config, pkgs, ... }:
let
  domain = "git.inclyc.cn";
  url = "https://${domain}";
in
{
  sops.secrets = {
    "gitea/runners/simd" = { };
    "gitea/runners/fuse-feature" = { };
    "gitea/runners/axplot" = { };
  };

  fonts.fonts = with pkgs; [
    corefonts
    vista-fonts
    vista-fonts-chs
    simsun
  ];

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
          python312
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
          bash
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

          (texlive.combine { inherit (texlive) scheme-full; })

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
      "axplot" = {
        inherit url;
        enable = true;
        name = "axplot";
        tokenFile = config.sops.secrets."gitea/runners/axplot".path;
        labels = [
          "native:host"
        ];
        hostPackages = with pkgs; [
          ninja
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
          python312
          pnpm
          nodejs
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
        "repository.signing" = {
          INITIAL_COMMIT = "always";
          CRUD_ACTIONS = "always";
          WIKI = "always";
          MERGES = "always";
        };
      };
    };
  };
}
