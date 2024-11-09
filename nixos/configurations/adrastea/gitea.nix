{ config, pkgs, ... }:
let
  domain = "git.inclyc.cn";
  url = "https://${domain}";
in
{

  sops.secrets = {
    "gitea/runners/fuse-feature" = { };
  };

  services.gitea-actions-runner.instances = {
    "fuse-feature/gpu" = {
      inherit url;
      name = "fuse-feature/gpu";
      enable = true;
      tokenFile = config.sops.secrets."gitea/runners/fuse-feature".path;
      labels = [
        "adrastea-gpu:host"
      ];
      hostPackages = with pkgs; [
        ninja
        bash
        coreutils
        curl
        gawk
        gitMinimal
        gnused
        nodejs
        wget
        cmake
        python3

        (texlive.combine { inherit (texlive) scheme-full; })

        poetry

        gnutar
        zstd

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
              cudatoolkit
              config.boot.kernelPackages.nvidia_x11
            ]);
          runScript = lib.getExe python3;
        })
      ];
    };
  };
}
