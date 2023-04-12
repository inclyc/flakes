{ pkgs, lib, config, ... }:
{
  imports = [
    ../common
  ];

  home.packages = with pkgs; [
    pinentry_mac
  ];

  home.homeDirectory = "/Users/${config.home.username}";
  home.username = "inclyc";

  inclyc.tex.enable = true;

  programs.vscode = {
    enable = true;
    userSettings = (builtins.fromJSON (builtins.readFile ./vscode-settings.json));
  };

  programs.ssh.matchBlocks.swyjs.proxyCommand = "ssh -W %h:%p adrastea";
}
