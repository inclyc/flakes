{
  pkgs ? (import ../nixpkgs.nix) { },
}:
{
  topsap = pkgs.callPackage ./topsap { };
  vscode-oss = pkgs.callPackage ./vscode-oss/package.nix { };
  wemeet = pkgs.callPackage ./wemeet/package.nix { };
}
