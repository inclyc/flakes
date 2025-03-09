{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation {
  pname = "simsun";
  version = "1.0.0";

  src = fetchurl {
    url = "https://raw.githubusercontent.com/gasharper/linux-fonts/9e4865ded110dbbb59a1aea5e40fe5b1569880f7/simsun.ttc";
    sha256 = "0rgqhjgjs7k6nckg6dmfzrlp7gwdvpgz6cyypj02xw18xdi6cana";
  };

  dontUnpack = true;

  installPhase = ''
    install -Dm644 $src $out/share/fonts/truetype/simsun.ttc
  '';

  meta = with lib; {
    description = "SimSun font";
    license = licenses.unfree;
    platforms = platforms.all;
  };
}
