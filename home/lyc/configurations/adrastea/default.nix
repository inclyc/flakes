{ pkgs, config, ... }:
{

  imports = [
    ./sops.nix
    ./topsap.nix
  ];

  home.packages = with pkgs; [
    # Web browser
    chromium

    # Phabricator CLI tools
    # For llvm-project
    arcanist
    graphviz
    kgraphviewer
  ];

  services.kdeconnect.enable = true;

  inclyc.tex.enable = true;

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

  programs.zsh.dirHashes = {
    flakes = "${config.home.homeDirectory}/workspace/CS/OS/NixOS/flakes";
    llvm = "${config.home.homeDirectory}/workspace/CS/Compilers/llvm-project";
  };
}
