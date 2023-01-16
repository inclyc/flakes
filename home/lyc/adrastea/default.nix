{ pkgs, lib, config, ... }:
{

  imports = (import ../common);

  home.packages = with pkgs; [
    tree
    tdesktop
    element-desktop
    firefox
    kate
    thunderbird
    nix-index
    nix-output-monitor
    nix-tree
    python3
    htop
    arcanist
    (pkgs.texlive.combine {
      inherit (pkgs.texlive) scheme-full;
    })
  ];


  gtk.gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";

  services.kdeconnect.enable = true;

  programs.vscode.userSettings = (builtins.fromJSON (builtins.readFile ./vscode-settings.json));

  services.gpg-agent = {
    enable = true;
    extraConfig = ''
      pinentry-program ${pkgs.pinentry-curses}/bin/pinentry-curses
    '';
  };
}
