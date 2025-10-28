{
  pkgs,
  ...
}:
let
  pyodide = pkgs.stdenv.mkDerivation rec {
    pname = "pyodide";
    version = "0.27.7";
    src = pkgs.fetchurl {
      url = "https://github.com/pyodide/pyodide/releases/download/${version}/pyodide-${version}.tar.bz2";
      sha256 = "0md7dr1n1mvdq5xjcib5b4g00xnzbflxm9z21zm100biqi7pzp88";
    };

    installPhase = ''
      mkdir -p $out
      cp -a . $out/
    '';

    dontFixup = true;
  };

  frontend-caddy =
    profile:
    (
      let
        frontend = pkgs.stdenvNoCC.mkDerivation {
          name = "axplot-frontend";
          src = pkgs.requireFile {
            name = "frontend.tar.gz";
            message = "Frontend dist tarball";
            sha256 = builtins.readFile ./${profile}/frontend.sha256;
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
        backendPort = builtins.readFile ./${profile}/backend.port;
      in
      ''
        root * ${frontend}/
        file_server
        handle_path /axplot/* {
          reverse_proxy 127.0.0.1:${backendPort}
        }
        handle_path /pyodide/*  {
          root * ${pyodide}
          file_server
          header Cache-Control "public, max-age=31536000, immutable"
        }
        @assets path /assets/*
        header @assets Cache-Control "public, max-age=31536000, immutable"
        @noCache path /index.html /
        handle @noCache {
            header Cache-Control "no-store, no-cache, must-revalidate"
            file_server
        }
      ''
    );
in
{
  imports = [
    ./backend.nix
  ];
  services.caddy = {
    enable = true;
    virtualHosts = {
      "axplot.inclyc.cn" = {
        extraConfig = frontend-caddy "production";
      };
      "testing.axplot.inclyc.cn" = {
        extraConfig = frontend-caddy "testing";
      };
    };
  };
}
