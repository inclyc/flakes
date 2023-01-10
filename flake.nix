{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";
    nur.url = github:nix-community/NUR;
  };

  outputs = { self, nixpkgs, nur, ... }@inputs: {

    nixosConfigurations = {
      lyc-desktop = import ./nixos/lyc-desktop { system = "x86_64-linux"; inherit self nixpkgs inputs; };
    };
  };
}
