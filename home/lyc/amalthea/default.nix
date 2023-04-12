{ pkgs, lib, config, ... }:
{
  imports = [
    ../common
  ];

  home.packages = with pkgs; [
    pinentry_mac
  ];

  home.homeDirectory = "/Users/${config.home.username}";

  inclyc.tex.enable = true;
  inclyc.user.unixName = lib.mkForce "inclyc";

  programs.vscode = {
    enable = true;
    userSettings = (builtins.fromJSON (builtins.readFile ./vscode-settings.json));
  };

  programs.ssh.matchBlocks.swyjs.proxyCommand = "ssh -W %h:%p adrastea";
}
