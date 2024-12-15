{
  pkgs ? (import ../nixpkgs.nix) { },
}:
{
  topsap = pkgs.callPackage ./topsap { };
  codium-reh = pkgs.callPackage ./codium-reh { };
  ddns = pkgs.python3.pkgs.callPackage ./ddns { };
}
