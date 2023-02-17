{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";
    nur.url = "github:nix-community/NUR";
    vscode-server.url = "github:msteen/nixos-vscode-server";
  };

  outputs = { self, nixpkgs, nur, home-manager, flake-utils, vscode-server, ... }@inputs:
    let
      inherit (self) outputs;
      forAllSystems = nixpkgs.lib.genAttrs flake-utils.lib.defaultSystems;
    in
    {
      nixosConfigurations = {
        # Desktop
        adrastea = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [ ./nixos/adrastea nur.nixosModules.nur ];
        };

        # Server, Dual AMD 7H12
        metis = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [
            ./nixos/metis
            vscode-server.nixosModule
            ({ config, pkgs, ... }: {
              services.vscode-server.enable = true;
            })
          ];
        };
      };

      homeConfigurations = {
        "lyc@metis" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."x86_64-linux";
          modules = [ ./home/lyc/metis ];
          extraSpecialArgs = { inherit inputs outputs; };
        };
        "lyc@adrastea" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."x86_64-linux";
          modules = [ ./home/lyc/adrastea ];
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
    )) // {
      overlays = import ./overlays;
      packages = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in import ./pkgs { inherit pkgs; }
      );
    };
}
