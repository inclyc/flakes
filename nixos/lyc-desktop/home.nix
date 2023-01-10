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
    python3
    htop
    (pkgs.texlive.combine {
      inherit (pkgs.texlive) scheme-full;
    })
  ];

  xdg.enable = true;
  gtk.gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";

  services.kdeconnect.enable = true;

  home.stateVersion = "22.11";
}
