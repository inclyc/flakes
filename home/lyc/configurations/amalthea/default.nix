{
  pkgs,
  lib,
  config,
  ...
}:
{
  home.packages = with pkgs; [
    pinentry_mac
    clash-meta
    qemu
  ];

  home.homeDirectory = "/Users/${config.home.username}";

  inclyc.tex.enable = false;
  inclyc.ssh.ICTProxy = true;

  programs.vscode = {
    enable = true;
    profiles.default.userSettings = (builtins.fromJSON (builtins.readFile ./vscode-settings.json));
  };
}
