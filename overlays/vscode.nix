final: prev:

let
  inherit (final) stdenv;
  inherit (stdenv.hostPlatform) system;
  archive_fmt = if stdenv.hostPlatform.isDarwin then "zip" else "tar.gz";
  throwSystem = (throw "Unsupported system: ${system}");
  plat =
    {
      x86_64-linux = "linux-x64";
      x86_64-darwin = "darwin";
      aarch64-linux = "linux-arm64";
      aarch64-darwin = "darwin-arm64";
      armv7l-linux = "linux-armhf";
    }
    .${system} or throwSystem;

  sha256 =
    {
      x86_64-linux = "11a0y0zdz3mmc2xvpnlq06a7q06y6529xpp4hlhpjylj0bk06xn1";
      x86_64-darwin = "12fxhwqcz36f5pv4kvs7bblmymxyixg7pvi0gb5k0j73pkvqrr6g";
      aarch64-linux = "0g5qz7gq7k65p2f8iwz1jiy03nwsmy3v3gb18qwg9mbhm0dk59la";
      aarch64-darwin = "1g4fz8nw5m7krjlsjs43937kz1sr7lkflbphpyh8cmalwpxa8ysn";
      armv7l-linux = "09r12y9xbpqnnw9mab3k4kx0ngpfng1l6rk09n9l2q36ji20ijmy";
    }
    .${system} or throwSystem;
in
{
  vscode = prev.vscode.overrideAttrs (old: rec {
    version = "1.97.2";
    rev = "e54c774e0add60467559eb0d1e229c6452cf8447";
    src = prev.fetchurl {
      name = "VSCode_${version}_${plat}.${archive_fmt}";
      url = "https://update.code.visualstudio.com/${version}/${plat}/stable";
      inherit sha256;
    };
  });
}
