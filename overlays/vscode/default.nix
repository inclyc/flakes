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
      x86_64-linux = "0pmjpjjafq36dr5dlf64bbkr6p697d2yc1z7l876i0vnw10g6731";
      x86_64-darwin = "1y32szp9asmchl64wfwz4jvhkr4441aykvy64qc8f4y51wxxxcnv";
      aarch64-linux = "0zbgbhnlg7wcgz8v34rknvblmdrac0l7qy5qfp2rn7jcdrm5qa53";
      aarch64-darwin = "00y6rz2cfz193n3svvsdknk6g38vg1w92yiqk5n14lyv2g8av2dc";
      armv7l-linux = "19q4rip33ma7krwpymp396ip5kwd5g8hp2n6jqcmljv59lw10c9h";
    }
    .${system} or throwSystem;
in
{
  vscode = prev.vscode.overrideAttrs (old: rec {
    version = "1.98.2";
    rev = "ddc367ed5c8936efe395cffeec279b04ffd7db78";
    src = prev.fetchurl {
      name = "VSCode_${version}_${plat}.${archive_fmt}";
      url = "https://update.code.visualstudio.com/${version}/${plat}/stable";
      inherit sha256;
    };
  });
}
