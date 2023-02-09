{ inputs, lib, pkgs, config, outputs, ... }:
{
  home.packages = [
    (pkgs.texlive.combine {
      inherit (pkgs.texlive) scheme-full;
    })
  ];
}
