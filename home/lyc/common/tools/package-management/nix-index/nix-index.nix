{ pkgs, lib, config, ... }:
{
  programs.nix-index = {
    enable = true;
    enableZshIntegration = true;
  };
}
