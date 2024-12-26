{
  pkgs ? (import ../nixpkgs.nix) { },
}:
{
  topsap = pkgs.callPackage ./topsap { };
  linux-fhs-python = pkgs.callPackage ./linux-fhs-python { };
  ddns = pkgs.python3.pkgs.callPackage ./ddns { };
  vscodium-remote-host = pkgs.callPackage ./vscodium-host {
    pname = "vscodium-remote-host";
    assetName = "vscodium-reh";
  };

  vscodium-web-host = pkgs.callPackage ./vscodium-host {
    pname = "vscodium-web-host";
    assetName = "vscodium-reh-web";
  };

}
