{ pkgs, lib, config, ... }:
{

  imports = (import ../../modules/home-manager);

  home.packages = with pkgs; [
    tree
    tdesktop
    element-desktop
    firefox
    kate
    thunderbird
    nix-index
    nix-output-monitor
    python3
    htop
    arcanist
    (pkgs.texlive.combine {
      inherit (pkgs.texlive) scheme-full;
    })
  ];


  gtk.gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";

  services.kdeconnect.enable = true;
}
