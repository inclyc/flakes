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
    # NixOS configurations
    let
      inherit (self) outputs;
      forAllSystems = nixpkgs.lib.genAttrs flake-utils.lib.defaultSystems;

      commonModules = (builtins.attrValues outputs.nixosModules) ++ [ nur.nixosModules.nur ];
      configurationDir = ./nixos/configurations;
      genConfig =
        { hostName
        }:
        {
          "${hostName}" = nixpkgs.lib.nixosSystem {
            modules = [ (configurationDir + "/${hostName}") ] ++ commonModules;
            specialArgs = { inherit inputs outputs; };
          };
        };
    in
    {
      nixosConfigurations = genConfig { hostName = "adrastea"; };
    } //
    (
      # Home-manager configurations
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
      nixosModules.lyc = import ./nixos/modules;
    };
}
