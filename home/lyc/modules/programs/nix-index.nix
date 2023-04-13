{ pkgs, lib, config, ... }:
{
  programs.nix-index = {
    enable = lib.mkDefault true;
    enableZshIntegration = true;
  };
}
