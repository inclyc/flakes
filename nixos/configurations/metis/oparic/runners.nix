{
  config,
  pkgs,
  lib,
  ...
}:
let
  url = config.services.gitea.settings.server.ROOT_URL;

  n = 5;

  packages = with pkgs; [
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

  names = map (i: "oparic-${toString i}") (lib.range 1 n);

in
{
  sops.secrets."gitea/runners/oparic" = { };

  services.gitea-actions-runner.instances = lib.listToAttrs (
    map (name: {
      name = name;
      value = {
        inherit url;
        enable = true;
        name = name;
        tokenFile = config.sops.secrets."gitea/runners/oparic".path;
        labels = [ "native:host" ];
        hostPackages = packages;
      };
    }) names
  );
}
