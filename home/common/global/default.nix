{ lib, config, ... }:
{
  imports = [
    ./xdg.nix
    ./nix.nix
  ];
  programs.home-manager.enable = true;
}
