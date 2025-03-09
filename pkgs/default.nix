{
  pkgs ? (import ../nixpkgs.nix) { },
}:
{
  topsap = pkgs.callPackage ./topsap { };
  linux-fhs-python = pkgs.callPackage ./linux-fhs-python { };
  ddns = pkgs.python3.pkgs.callPackage ./ddns { };

  vscode-web-host = pkgs.callPackage ./vscode-host { };

  vscodium-remote-host = pkgs.callPackage ./vscodium-host {
    pname = "vscodium-remote-host";
    assetName = "vscodium-reh";
  };

  vscodium-web-host = pkgs.callPackage ./vscodium-host {
    pname = "vscodium-web-host";
    assetName = "vscodium-reh-web";
  };

  simsun = pkgs.callPackage ./simsun { };

}
