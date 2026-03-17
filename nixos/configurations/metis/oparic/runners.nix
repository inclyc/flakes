{
  config,
  pkgs,
  lib,
  utils,
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

  proxyEnvs = {
    all_proxy = "socks5://127.0.0.1:8899";
    http_proxy = "http://127.0.0.1:8899";
    https_proxy = "http://127.0.0.1:8899";
    no_proxy = "localhost,127.0.0.1,.local";
  };
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
        settings = {
          runner = {
            envs = proxyEnvs;
          };
        };
      };
    }) names
  );

  systemd.services = lib.listToAttrs (
    map (name: {
      name = "gitea-runner-${utils.escapeSystemdPath name}";
      value = {
        environment = proxyEnvs;
        # This service starts the proxy port, so the runner must start after it
        wants = [ "xscribe.service" ];
        after = [ "xscribe.service" ];
      };
    }) names
  );
}
