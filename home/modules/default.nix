{ ... }:
{
  imports = [
    ./xdg.nix
    ./nix.nix
    ./user.nix
    ./tex.nix
  ];

  programs.home-manager.enable = true;
}
