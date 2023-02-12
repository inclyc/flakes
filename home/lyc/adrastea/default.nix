{ pkgs, lib, config, ... }:
{

  imports = (import ../common);

  home.packages = with pkgs; [
    # Social media, chatting
    tdesktop
    element-desktop
    qq

    # Web browser
    firefox
    kate
    thunderbird

    # Phabricator CLI tools
    # For llvm-project
    arcanist
  ];


  gtk.gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";

  services.kdeconnect.enable = true;

  programs.vscode = {
    userSettings = (builtins.fromJSON (builtins.readFile ./vscode-settings.json));
    extensions = with pkgs.vscode-extensions; [
      vadimcn.vscode-lldb
    ];
  };

  services.gpg-agent = {
    enable = true;
    extraConfig = ''
      pinentry-program ${pkgs.pinentry-curses}/bin/pinentry-curses
    '';
  };
}
