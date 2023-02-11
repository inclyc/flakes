{ pkgs, lib, config, ... }:
{
  programs.tmux = {
    enable = true;
    mouse = true;
    newSession = true;
    shell = "${pkgs.zsh}/bin/zsh";
  };
}
