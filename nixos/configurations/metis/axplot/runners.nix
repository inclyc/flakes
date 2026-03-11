{
  config,
  pkgs,
  lib,
  ...
}:
let
  url = config.services.gitea.settings.server.ROOT_URL;

  n = 5;

  axplotPackages = with pkgs; [
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
    nix
  ];
in
{
  sops.secrets."gitea/runners/axplot" = { };

  services.gitea-actions-runner.instances = lib.listToAttrs (
    map (
      i:
      let
        name = "axplot-${toString i}";
      in
      {
        name = name;
        value = {
          inherit url;
          enable = true;
          name = name;
          tokenFile = config.sops.secrets."gitea/runners/axplot".path;
          labels = [ "native:host" ];
          hostPackages = axplotPackages;
        };
      }
    ) (lib.range 1 n)
  );
}
