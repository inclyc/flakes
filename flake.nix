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
      forAllSystems = nixpkgs.lib.genAttrs flake-utils.lib.defaultSystems;
    in
    {
      nixosConfigurations = {
        # Desktop
        adrastea = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [
            ./nixos/adrastea
            nur.nixosModules.nur
          ];
        };

        # Server, Dual AMD 7H12
        metis = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [ ./nixos/metis ];
        };
      };
    } //
    (
      let
        commonHomeModules = builtins.attrValues outputs.homeModules;
        configurationDir = ./home/lyc/configurations;
        genConfig =
          { unixName ? "lyc"
          , hostName
          , system ? "x86_64-linux"
          }:
          {
            "${unixName}@${hostName}" = home-manager.lib.homeManagerConfiguration {
              pkgs = nixpkgs.legacyPackages."${system}";
              modules = [ (configurationDir + "/${hostName}") ] ++ commonHomeModules;
              extraSpecialArgs = { inherit inputs outputs; };
            };
          };
      in
      {
        homeConfigurations = genConfig { hostName = "metis"; }
        // genConfig { hostName = "adrastea"; }
        // genConfig { hostName = "ict-malcon"; }
        // genConfig {
          unixName = "inclyc";
          hostName = "amalthea";
          system = "aarch64-darwin";
        };
      }
    )
    // (flake-utils.lib.eachDefaultSystem (system:
      {
        devShells.default = nixpkgs.legacyPackages.${system}.callPackage ./shell.nix { };
      }
    )) // {
      overlays = import ./overlays;
      packages = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in import ./pkgs { inherit pkgs; }
      );
      homeModules = {
        lyc = import ./home/lyc/modules;
        common = import ./home/modules;
      };
    };
}
