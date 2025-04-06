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
      x86_64-linux = "1fds83amgkzp9nz7cvs432ilr602lr45h916vkq8qhpbb84ildd2";
      x86_64-darwin = "1pmda39jz05d0g3k6rgavhwmgxkldmarbj59fd9i0b5dcspzybxf";
      aarch64-linux = "148cpbhz14aldqklnma9mpakylkx2qk86k5ppij0zlqb5m6mgnaz";
      aarch64-darwin = "10v37bcl8wg4j5snd7n3l7zwqf51vkx4cs2abf33ysazmafvnfpd";
      armv7l-linux = "10vfnk87g4agwp0phh7l9k7hg727n1l4fcvqn1bxbrix9hbq7bbc";
    }
    .${system} or throwSystem;
in
{
  vscode = prev.vscode.overrideAttrs (old: rec {
    version = "1.99.0";
    rev = "4437686ffebaf200fa4a6e6e67f735f3edf24ada";
    src = prev.fetchurl {
      name = "VSCode_${version}_${plat}.${archive_fmt}";
      url = "https://update.code.visualstudio.com/${version}/${plat}/stable";
      inherit sha256;
    };
  });
}
