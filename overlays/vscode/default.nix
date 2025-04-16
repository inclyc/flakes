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
      x86_64-linux = "0hb1rmrrd7zjihrl080h7jf4dprpr7mvm3ykv13mg0xmmv0d7pww";
      x86_64-darwin = "0bf69y7xxn499r35zxliqx0jvhyd11b46p5a87w62g90q4kcald8";
      aarch64-linux = "05zjk3l05lxh21anxxds6fn98fxlkrak37sz79jg50cxrpn5jvxg";
      aarch64-darwin = "1sjvj4d0d3mcjczb1sjia6gl34vkr91z7jxbyqbf5c88j3zybvw5";
      armv7l-linux = "1m7g179hlz2kri0pqsaigdyfnkkv4xwaxmxrbdpxh0sjb2imv8x2";
    }
    .${system} or throwSystem;
in
{
  vscode = prev.vscode.overrideAttrs (old: rec {
    version = "1.99.2";
    rev = "4949701c880d4bdb949e3c0e6b400288da7f474b";
    src = prev.fetchurl {
      name = "VSCode_${version}_${plat}.${archive_fmt}";
      url = "https://update.code.visualstudio.com/${version}/${plat}/stable";
      inherit sha256;
    };
  });
}
