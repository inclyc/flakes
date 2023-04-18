{ pkgs ? (import ../nixpkgs.nix) { } }: {
  ddns = pkgs.python3.pkgs.callPackage ./ddns { };
}
