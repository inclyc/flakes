{ pkgs, lib, config, ... }:
{

  imports = (import ../../modules);

  home.packages = with pkgs; [
    tree
    tdesktop
    firefox
    kate
    thunderbird
    nix-index
    nix-output-monitor
  ];

  xdg.enable = true;
  gtk.gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";

  home.stateVersion = "22.11";
}
