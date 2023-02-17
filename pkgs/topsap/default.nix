{ stdenv
, fetchurl
, lib
, dpkg
, autoPatchelfHook
, libX11
, webkitgtk
, libsoup
, libkrb5
, jasper
, libtiff
, librsvg
, libXxf86vm
, gdk-pixbuf
, gst_all_1
, glib
, writeShellScript
, ...
} @ args:

let
  resource = stdenv.mkDerivation
    rec {
      pname = "topsap-unwrapped";
      version = "3.5.2.35.2";
      src = fetchurl {
        url = "https://app.topsec.com.cn/vpn/sslvpnclient/TopSAP-${version}-x86_64.deb";
        sha256 = "sha256-wBD39gHS5fWOEhOgEVB3a/McbaxYJyL0sclqDA4xLWo=";
      };

      nativeBuildInputs = [
        autoPatchelfHook
        dpkg
      ];

      buildInputs = [
        libX11
        webkitgtk
        libsoup
        libkrb5
        jasper
        libtiff
        librsvg
        libXxf86vm
        gdk-pixbuf
        gst_all_1.gstreamer
        glib
      ];

      dontUnpack = true;

      installPhase = ''
        dpkg-deb -x ${src} .
        sh opt/TopSAP/TopSAP*.bin --target $name --noexec
        mkdir $out

        rm -rf $name/common/lib/gdk-pixbuf-2.0
        rm -rf $name/common/lib/libglib-2.0.so.0

        cp -r $name/common/. $out/
        cp -r $name/ubuntu/. $out/
      '';
    };

  sv_websrv = writeShellScript "sv_websrv" ''
    trap "rm libvpn_client.so" SIGINT SIGTERM SIGQUIT
    ln -s ${resource}/libvpn_client.so .

    ${resource}/sv_websrv
  '';
in
stdenv.mkDerivation {
  pname = "top";
  version = "3.5.2.35.2";
  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/bin
    ln -s ${sv_websrv} $out/bin/sv_websrv
    ln -s ${resource}/topvpn $out/bin/topvpn
  '';
}
