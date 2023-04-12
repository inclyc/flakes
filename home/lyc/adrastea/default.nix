{ pkgs, lib, config, ... }:
{

  imports = [
    ../common
  ];

  home.packages = with pkgs; [
    # Social media, chatting
    qq

    # Web browser
    chromium

    # Phabricator CLI tools
    # For llvm-project
    arcanist
    graphviz
    kgraphviewer
  ];

  services.kdeconnect.enable = true;

  programs.vscode = {
    enable = true;
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
