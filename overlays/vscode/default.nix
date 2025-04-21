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
      x86_64-linux = "0d9qfifxslwkyv9v42y2h7nbqndq5w16z08qar4vly1hnjnmzzxl";
      x86_64-darwin = "1yyfkgif0nyhgb28wn1wmdq9wyzxybgdfp8j9nknh0nmvmf1r9w6";
      aarch64-linux = "05xj9fswgf24l9mx98hcapzq90820dwwp9mskbbzai3kxy915yqx";
      aarch64-darwin = "0a41szz9gljf31pq5czqwiyrxms5cf1x1058rsacaihvx8vn38ya";
      armv7l-linux = "0iq3y8vj4gm20bxkcrsrnb3g0nf5lg5mpb1bxrg2cy4dgaxjl170";
    }
    .${system} or throwSystem;
in
{
  vscode = prev.vscode.overrideAttrs (old: rec {
    version = "1.99.3";
    rev = "17baf841131aa23349f217ca7c570c76ee87b957";
    src = prev.fetchurl {
      name = "VSCode_${version}_${plat}.${archive_fmt}";
      url = "https://update.code.visualstudio.com/${version}/${plat}/stable";
      inherit sha256;
    };
  });
}
