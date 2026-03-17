{
  pkgs,
  ...
}:
let
  frontend-caddy =
    profile:
    (
      let
        backendPort = builtins.readFile ./${profile}/backend.port;
        workflow-static = pkgs.stdenvNoCC.mkDerivation {
          name = "workflow-static";
          src = pkgs.requireFile {
            name = "workflow-static.tar.gz";
            message = "Static files for workflow";
            sha256 = builtins.readFile ./${profile}/workflow-static.sha256;
          };
          dontUnpack = true;
          installPhase = ''
            runHook preInstall
            mkdir -p $out
            tar xzf $src -C $out/
            runHook postInstall
          '';
          nativeBuildInputs = with pkgs; [
            gnutar
          ];
        };
      in
      ''
        handle /axplot/* {
          reverse_proxy 127.0.0.1:${backendPort}
        }
        handle_path /workflow-static/*  {
          root * ${workflow-static}
          file_server
          header Cache-Control "public, max-age=31536000, immutable"
        }
      ''
    );
in
{
  imports = [
    ./backend.nix
    ./runners.nix
  ];
  services.caddy = {
    enable = true;
    virtualHosts = {
      "axplot.inclyc.cn" = {
        extraConfig = frontend-caddy "production";
      };
      "src.testing.axplot.inclyc.cn" = {
        extraConfig = frontend-caddy "testing";
      };
      "posthog.inclyc.cn" = {
        extraConfig = "reverse_proxy 192.168.31.5:80";
      };
    };
  };
}
