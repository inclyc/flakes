{ inputs, lib, pkgs, config, outputs, ... }:
with lib;
let
  cfg = config.inclyc.tex;
in
{
  options = {
    inclyc.tex.enable = mkEnableOption "TeXLive Full";
  };
  config = mkIf cfg.enable {
    home.packages = [
      (pkgs.texlive.combine {
        inherit (pkgs.texlive) scheme-full;
      })
    ];
  };
}
