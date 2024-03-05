{ pkgs, lib, config, ... }:
{

  imports = [
    ./ssh-proxy.nix
  ];

  home.packages = with pkgs; [
    pinentry_mac
    clash-meta
    qemu
  ];

  home.homeDirectory = "/Users/${config.home.username}";

  inclyc.tex.enable = false;

  programs.vscode = {
    enable = true;
    userSettings = (builtins.fromJSON (builtins.readFile ./vscode-settings.json));
  };
}
