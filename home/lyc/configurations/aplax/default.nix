{ pkgs, config, lib, ... }:
{
  programs.vscode.enable = true;

  home.homeDirectory = "/Users/${config.home.username}";

  programs.zsh.dirHashes = {
    flakes = "${config.home.homeDirectory}/flakes";
  };

  inclyc.ssh.ICTProxy = true;

  home.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
    (lib.hiPrio clang-tools_16)
    clash-meta
    pinentry_mac
    qemu
  ];
}
