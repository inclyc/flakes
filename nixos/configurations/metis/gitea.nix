{ config, pkgs, ... }:
let
  domain = "git.inclyc.cn";
  url = "https://${domain}";
in
{
  sops.secrets."gitea/runners/simd" = { };

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
          gcc8
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
