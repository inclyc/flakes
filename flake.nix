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

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };

    flake-utils.url = "github:numtide/flake-utils";

    flake-compat = {
      url = "github:inclyc/flake-compat";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      flake-parts,
      sops-nix,
      ...
    }@inputs:
    let
      devShellsDir = ./devShells;
      nixosConfigDir = ./nixos/configurations;
      inherit (self) outputs;
      rootPath = ./.;
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = flake-utils.lib.defaultSystems;
      perSystem =
        {
          pkgs,
          ...
        }:
        {
          devShells =
            nixpkgs.lib.mapAttrs' (
              f: _:
              nixpkgs.lib.nameValuePair (nixpkgs.lib.removeSuffix ".nix" f) (
                import (devShellsDir + "/${f}") { inherit pkgs; }
              )
            ) (builtins.readDir devShellsDir)
            // {
              default = import ./shell.nix { inherit pkgs; };
            };
          packages = import ./pkgs { inherit pkgs; };
        };
      flake =
        {
          nix.settings = {
            # nix substituters shared between home-manager and nixos
            substituters =
              let
                channelStore = x: "https://${x}/nix-channels/store";
                mirrors = map (x: channelStore "mirrors.${x}.edu.cn") [
                  "bfsu"
                  "tuna.tsinghua"
                  "ustc"
                ];
                cachix = x: "https://${x}.cachix.org";
              in
              nixpkgs.lib.flatten [
                mirrors
                (cachix "nix-community")
                "https://cache.nixos.org"
                (cachix "inclyc")
              ];
          };
          nixosModules.lyc = import ./nixos/modules;
          nixosConfigurations =
            nixpkgs.lib.genAttrs
              (map (f: nixpkgs.lib.removeSuffix ".nix" f) [
                "adrastea"
                "metis"
                "luna"
              ])
              (
                hostName:
                nixpkgs.lib.nixosSystem {
                  modules =
                    [ (nixosConfigDir + "/${hostName}") ]
                    ++ [
                      outputs.nixosModules.lyc
                      sops-nix.nixosModules.sops
                    ];
                  specialArgs = {
                    inherit inputs outputs rootPath;
                  };
                }
              );
          overlays = {
            additions = final: _prev: import ./pkgs { pkgs = final; };
            modifications = import ./overlays/modifications.nix;
          };
        }
        // (
          # Home-manager configurations
          let
            mkHomeConfig =
              {
                hostName,
                unixName ? "lyc",
                system ? "x86_64-linux",
                nixpkgs ? inputs.nixpkgs,
                home-manager ? inputs.home-manager,
              }:
              {
                "${unixName}@${hostName}" = home-manager.lib.homeManagerConfiguration {
                  pkgs = nixpkgs.legacyPackages.${system};
                  modules = [
                    (./home/lyc/configurations + "/${hostName}")
                    sops-nix.homeManagerModules.sops
                  ] ++ (builtins.attrValues outputs.homeManagerModules);
                  extraSpecialArgs = {
                    inherit
                      inputs
                      outputs
                      rootPath
                      unixName
                      hostName
                      system
                      ;
                  };
                };
              };
          in
          {
            homeConfigurations =
              nixpkgs.lib.foldr (a: b: a // b) { } (
                map (hostName: mkHomeConfig { inherit hostName; }) [
                  # Simple home configuration, only specified "hostName"
                  "adrastea"
                  "metis"
                  "ict-malcon"
                ]
              )
              // mkHomeConfig {
                hostName = "amalthea";
                system = "aarch64-darwin";
              }
              // mkHomeConfig {
                hostName = "aplax";
                system = "aarch64-darwin";
              }
              // mkHomeConfig {
                hostName = "luna";
                system = "aarch64-linux";
              }
              // mkHomeConfig {
                hostName = "aplaz";
                system = "aarch64-linux";
              };
            homeManagerModules = {
              lyc = import ./home/lyc/modules;
              common = import ./home/modules;
            };
          }
        );
    };
}
