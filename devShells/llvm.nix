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
    ccache

    # for "lit" testing
    python3

    clang-tools
  ];

  # workaround for https://github.com/NixOS/nixpkgs/issues/76486
  shellHook = ''
    PATH="${clang-tools}/bin:$PATH"
  '';
}
