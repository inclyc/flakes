# This file (and the global directory) holds config that i use on all hosts
{
  inputs,
  outputs,
  pkgs,
  ...
}:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./clash
    ./nix.nix
    ./rathole.nix
    ./ddns.nix
    ./nix-ld.nix
    ./gui.nix
    ./user.nix
    ./dae
    ./sops.nix

    # Language-specific environments
    ./rust.nix
    ./python.nix

    # Services to external world
    ./code-server.nix
  ];

  home-manager = {
    useUserPackages = true;
    extraSpecialArgs = {
      inherit inputs outputs;
    };
  };

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
    home-manager
  ];
}
