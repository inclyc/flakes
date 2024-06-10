{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.inclyc.tex;
  inherit (lib) mkEnableOption mkIf;
in
{
  options = {
    inclyc.tex.enable = mkEnableOption "TeXLive Full";
  };
  config = mkIf cfg.enable {
    home.packages = [ (pkgs.texlive.combine { inherit (pkgs.texlive) scheme-full; }) ];
  };
}
