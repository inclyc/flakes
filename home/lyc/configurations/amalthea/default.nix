{ pkgs, lib, config, ... }:
{

  home.packages = with pkgs; [
    pinentry_mac
  ];

  home.homeDirectory = "/Users/${config.home.username}";

  inclyc.tex.enable = false;

  programs.vscode = {
    enable = true;
    userSettings = (builtins.fromJSON (builtins.readFile ./vscode-settings.json));
  };

  programs.ssh.matchBlocks.swyjs.proxyCommand = "nc -x 127.0.0.1:1081 %h %p";
}
