{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";
    nur.url = "github:nix-community/NUR";
  };

  outputs = { self, nixpkgs, nur, home-manager, flake-utils, ... }@inputs:
    let
      inherit (self) outputs;
    in
    {
      nixosConfigurations = {
        # Desktop
        adrastea = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [ ./nixos/adrastea nur.nixosModules.nur ];
        };
      };

      homeConfigurations = {
        "lyc@adrastea" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."x86_64-linux";
          modules = [ ./home/lyc/adrastea ];
          extraSpecialArgs = { inherit inputs outputs; };
        };
        "lyc@hellsegga" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."x86_64-linux";
          modules = [ ./home/lyc/hellsegga ];
          extraSpecialArgs = { inherit inputs outputs; };
        };
        "inclyc@amalthea" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."aarch64-darwin";
          modules = [ ./home/lyc/amalthea ];
          extraSpecialArgs = { inherit inputs outputs; };
        };
      };
    } // (flake-utils.lib.eachDefaultSystem (system:
      {
        devShells.default = nixpkgs.legacyPackages.${system}.callPackage ./shell.nix { };
      }
    ));
}
