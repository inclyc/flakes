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
      x86_64-linux = "12606f4b6drp9gnb2y6q8b9zd1q7pjqg4ikjsfz47wgsi4009096";
      x86_64-darwin = "18hj3n81ja0kj4l4l1v2s3ahgagl9p7bv0zzmj710vqpr3k3h2p8";
      aarch64-linux = "03k92827lvb7rnavpii1kx0z3rpxsmbv21rdi06w5agpk4l3xs9k";
      aarch64-darwin = "08x5gv338yf1by04djvykjwnlifffb1bfbqr6vnxshcy9r30n925";
      armv7l-linux = "05cchap0r3vxfa32i3di838kj6wyrsm2qcga0gcl2aa27c86cn3c";
    }
    .${system} or throwSystem;
in
{
  vscode = prev.vscode.overrideAttrs (old: rec {
    version = "1.96.2";
    rev = "fabdb6a30b49f79a7aba0f2ad9df9b399473380f";
    src = prev.fetchurl {
      name = "VSCode_${version}_${plat}.${archive_fmt}";
      url = "https://update.code.visualstudio.com/${version}/${plat}/stable";
      inherit sha256;
    };
  });
}
