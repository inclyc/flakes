{
  pkgs,
  inputs,
  outputs,
  lib,
  ...
}:
{
  nix = {
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    settings = {
      inherit (outputs.nix.settings) substituters;
      trusted-users = [
        "root"
        "@wheel"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "inclyc.cachix.org-1:izGZ+f/JLPovKX1OKd3rQZ8nPOCpvPij3+bebjxdZ2k="
      ];
      auto-optimise-store = lib.mkDefault true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      warn-dirty = false;
      system-features = [
        "kvm"
        "big-parallel"
      ];
      use-xdg-base-directories = true;
      builders-use-substitutes = true;
    };
    package = pkgs.nix;
    registry.sys = lib.mkDefault {
      from = {
        type = "indirect";
        id = "sys";
      };
      flake = inputs.nixpkgs;
    };
  };
}
