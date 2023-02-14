# This file (and the global directory) holds config that i use on all hosts
{ lib, inputs, outputs, pkgs, ... }:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./nix.nix
  ];

  home-manager = {
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs outputs; };
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  # Increase open file limit for sudoers
  security.pam.loginLimits = [
    {
      domain = "@wheel";
      item = "nofile";
      type = "soft";
      value = "524288";
    }
    {
      domain = "@wheel";
      item = "nofile";
      type = "hard";
      value = "1048576";
    }
  ];


  environment.systemPackages = with pkgs; [
    wget
    neofetch
    git
    tree-sitter
    file

    # Toolchain
    gcc
    cmake
    ninja
    ccache

    # NixOS
    home-manager
    patchelf
    nix-review
  ] ++ (
    # LLVM Packages
    let
      llvmpkg = pkgs.llvmPackages_15;
    in
    (with llvmpkg; [
      clang
      llvm
      bintools
    ])
  );
}
