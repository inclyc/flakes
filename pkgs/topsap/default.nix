{ stdenv
, fetchurl
, dpkg
, libuuid
, buildFHSUserEnvBubblewrap
, ...
}:

let
  topsap-unwrapped = stdenv.mkDerivation
    rec {
      pname = "topsap-unwrapped";
      version = "3.5.2.36.2";
      src = fetchurl {
        url = "https://app.topsec.com.cn/vpn/sslvpnclient/TopSAP-${version}-x86_64.deb";
        sha256 = "sha256-I859oVKa7n3VGIZvzu0h0bYXGFg27jxd5GHsnX7Y+yE=";
      };

      nativeBuildInputs = [ dpkg ];

      dontUnpack = true;

      installPhase = ''
        dpkg-deb -x ${src} .
        sh opt/TopSAP/TopSAP*.bin --target $name --noexec

        mkdir -p $out/bin

        cp $name/common/topvpn $out/bin
        cp $name/common/sv_websrv $out/bin
        cp $name/common/libvpn_client.so $out/bin
      '';
    };
  sv_websrv = buildFHSUserEnvBubblewrap {
    name = "sv_websrv";
    runScript = "${topsap-unwrapped}/bin/sv_websrv";
    targetPkgs = pkgs: [ libuuid ];
    unshareUser = false; # Needs TUN device access

    # Hardcoded "./libvpn_client.so", symlink this from nix store
    extraBwrapArgs = [
      "--tmpfs $(pwd)"
      "--symlink ${topsap-unwrapped}/bin/libvpn_client.so $(pwd)/libvpn_client.so"
    ];
  };
in
stdenv.mkDerivation {
  pname = "topsap";
  inherit (topsap-unwrapped) version;
  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/bin
    ln -s ${sv_websrv}/bin/sv_websrv $out/bin/sv_websrv
    ln -s ${topsap-unwrapped}/bin/topvpn $out/bin/topvpn
  '';
}
