{
  pkgs ? (import ../nixpkgs.nix) { },
}:
{
  topsap = pkgs.callPackage ./topsap { };
  codium-reh = pkgs.callPackage ./codium-reh { };
  linux-fhs-python = pkgs.callPackage ./linux-fhs-python { };
  ddns = pkgs.python3.pkgs.callPackage ./ddns { };
}
