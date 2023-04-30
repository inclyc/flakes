{ pkgs
, ...
}:
let
  llvmPackages = pkgs.llvmPackages_15;
  stdenv = llvmPackages.stdenv;
in
with pkgs; pkgs.mkShell.override { inherit stdenv; }
{
  nativeBuildInputs = [
    cmake
    ninja
  ];
}
