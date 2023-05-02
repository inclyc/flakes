# This file (and the global directory) holds config that i use on all hosts
{ outputs, pkgs, ... }:
{
  imports = [
    ./nix.nix
    ./ddns.nix
    ./nix-ld.nix
    ./gui.nix
    ./user.nix
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
    overlays = [
      outputs.overlays.modifications
      outputs.overlays.additions
    ];
  };

  environment.systemPackages = with pkgs; [
    git
  ];
}
