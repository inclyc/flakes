{ inputs, lib, pkgs, config, outputs, ... }:
{
  imports = [
    ../../common/global
  ];

  home = {
    stateVersion = lib.mkDefault "22.11";
    packages = with pkgs; [
      tree
      nix-index
      nix-output-monitor
      nix-tree
      python3
      htop

      # C/C++ build system
      cmake
      meson
      bear
    ];
  };

  xdg.enable = lib.mkDefault true;
}
