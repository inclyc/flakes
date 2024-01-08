{ config, lib, pkgs, ... }:

let
  cfg = config.inclyc.development.rust;
in
{
  options = {
    inclyc.development.rust.enable = lib.mkEnableOption "rust development";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      rustc
      cargo
      rust-analyzer
      rustfmt
      clippy
    ];
    environment.sessionVariables = {
      RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
    };
  };
}
