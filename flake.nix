{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";

    flake-utils.url = "github:numtide/flake-utils";
    nur.url = "github:nix-community/NUR";
  };

  outputs =
    { self
    , nixpkgs
    , nur
    , home-manager
    , flake-utils
    , sops-nix
    , nix-vscode-extensions
    , ...
    }@inputs:
    # NixOS configurations
    let
      inherit (self) outputs;
      rootPath = ./.;

      commonModules = (builtins.attrValues outputs.nixosModules)
        ++ [
        nur.nixosModules.nur
        sops-nix.nixosModules.sops
      ];
      configurationDir = ./nixos/configurations;
      genConfig = hostName: {
        "${hostName}" = nixpkgs.lib.nixosSystem {
          modules = [ (configurationDir + "/${hostName}") ] ++ commonModules;
          specialArgs = { inherit inputs outputs rootPath; };
        };
      };
    in
    {
      nixosConfigurations = genConfig "adrastea"
      // (genConfig "metis");
    } //
    (
      # Home-manager configurations
      let
        commonhomeManagerModules = builtins.attrValues outputs.homeManagerModules
        ++ [ sops-nix.homeManagerModules.sops ];
        configurationDir = ./home/lyc/configurations;
        genConfig =
          { unixName ? "lyc"
          , hostName
          , system ? "x86_64-linux"
          }:
          {
            "${unixName}@${hostName}" = home-manager.lib.homeManagerConfiguration {
              pkgs = nixpkgs.legacyPackages."${system}";
              modules = [ (configurationDir + "/${hostName}") ] ++ commonhomeManagerModules;
              extraSpecialArgs = { inherit inputs outputs rootPath unixName hostName system; };
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
    let
      devShellsDir = ./devShells;
      pkgs = nixpkgs.legacyPackages.${system};
      devShellsConfig = shellName: {
        "${shellName}" = import (devShellsDir + "/${shellName}") { inherit pkgs; };
      };
    in
    {
      devShells = devShellsConfig "llvm" // {
        default = nixpkgs.legacyPackages.${system}.callPackage ./shell.nix { };
      };
      packages = import ./pkgs { inherit pkgs; };
    }
    )) // {
      overlays = {
        additions = final: _prev: import ./pkgs { pkgs = final; };
        modifications = final: prev: { };
      };
      homeManagerModules = {
        lyc = import ./home/lyc/modules;
        common = import ./home/modules;
      };
      nixosModules.lyc = import ./nixos/modules;
    };
}
