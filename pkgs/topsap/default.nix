{ stdenv
, fetchurl
, perl
, dpkg
, libuuid
, buildFHSUserEnvBubblewrap
, autoPatchelfHook
, ...
}:
stdenv.mkDerivation rec {
  pname = "topsap";
  version = "3.5.2.36.2";
  src = fetchurl {
    url = "https://app.topsec.com.cn/vpn/sslvpnclient/TopSAP-${version}-x86_64.deb";
    sha256 = "sha256-I859oVKa7n3VGIZvzu0h0bYXGFg27jxd5GHsnX7Y+yE=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
  ];

  buildInputs = [
    stdenv.cc.cc
    libuuid
  ];


  unpackCmd = "dpkg -x $curSrc source";

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    sh opt/TopSAP/TopSAP*.bin --target $name --noexec

    mkdir -p $out/{bin,lib}

    cp $name/common/topvpn $out/bin
    cp $name/common/sv_websrv $out/bin

    # ELF hack, sv_websrv tries to dlopen "./libvpn_client.so"
    # Let's patch "./libvpn_client.so" -> "libvpn_client.so\0\0"
    # man:dlopen(3) said: if it is a relative or absolute path, DT_RUNPATH will not be searched.
    ${perl}/bin/perl -0777 -pe 's/\.\/libvpn_client\.so/substr q{libvpn_client.so}."\0"x length$&,0,length$&/e or die "pattern not found"' -i $out/bin/sv_websrv
    cp $name/common/libvpn_client.so $out/lib
  '';

  postFixup = ''
    patchelf --add-needed libvpn_client.so \
             --add-rpath $out/lib \
             $out/bin/sv_websrv
  '';
}
