{
  pkgs ? (import ../nixpkgs.nix) { },
}:
{
  topsap = pkgs.callPackage ./topsap { };
  ddns = pkgs.python3.pkgs.callPackage ./ddns { };
}
