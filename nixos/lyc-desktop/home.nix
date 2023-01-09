{ pkgs, lib, config, ... }:
{

  imports = (import ../../modules);

  home.packages = with pkgs; [
    tree
    tdesktop
    firefox
    kate
    thunderbird
    nix-index
    nix-output-monitor
  ];

  xdg.enable = true;

  home.stateVersion = "22.11";
}
