{
  pkgs ? (import ../nixpkgs.nix) { },
}:
{
  topsap = pkgs.callPackage ./topsap { };
  code-oss = pkgs.callPackage ./code-oss/package.nix { };
  ddns = pkgs.python3.pkgs.callPackage ./ddns { };
}
