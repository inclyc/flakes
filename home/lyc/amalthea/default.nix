{ pkgs, lib, config, ... }:
{
  imports = (import ../common);

  home.packages = with pkgs; [
    pinentry_mac
  ];
  home.homeDirectory = "/Users/${config.home.username}";
  home.username = "inclyc";

  programs.vscode.userSettings = (builtins.fromJSON (builtins.readFile ./vscode-settings.json));

  programs.ssh.matchBlocks.swyjs.proxyCommand = "ssh -W %h:%p adrastea";
}
