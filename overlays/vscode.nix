final: prev:

let
  inherit (final) stdenv;
  inherit (stdenv.hostPlatform) system;
  archive_fmt = if stdenv.hostPlatform.isDarwin then "zip" else "tar.gz";
  plat =
    {
      x86_64-linux = "linux-x64";
      x86_64-darwin = "darwin";
      aarch64-linux = "linux-arm64";
      aarch64-darwin = "darwin-arm64";
      armv7l-linux = "linux-armhf";
    }
    .${system} or (throw "Unsupported system: ${system}");
in
{
  vscode = prev.vscode.overrideAttrs (old: rec {
    version = "1.96.2";
    rev = "fabdb6a30b49f79a7aba0f2ad9df9b399473380f";
    src = prev.fetchurl {
      name = "VSCode_${version}_${plat}.${archive_fmt}";
      url = "https://update.code.visualstudio.com/${version}/${plat}/stable";
      sha256 = "sha256-RSQLRk6eQd3tNhkvt8JyzkVquZx+y0aAX8F5NMZ+pSM=";
    };
  });
}
