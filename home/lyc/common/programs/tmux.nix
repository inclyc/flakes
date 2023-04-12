{ pkgs, lib, ... }:
{
  programs.tmux = {
    enable = lib.mkDefault true;
    mouse = true;
    newSession = true;
    shell = "${pkgs.zsh}/bin/zsh";
  };
}
