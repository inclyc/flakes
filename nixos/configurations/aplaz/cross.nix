# Specify cross-builds on aplaz.
{
  pkgs,
  inputs,
  lib,
  config,
  ...
}:
let
  pkgsX86Cross = import pkgs.path {
    crossSystem.system = "aarch64-linux";
    localSystem.system = "x86_64-linux";
    overlays = [ inputs.nixos-apple-silicon.overlays.apple-silicon-overlay ];
  };
in
{
  nix.buildMachines = [
    {
      hostName = "metis";
      system = "x86_64-linux";
      protocol = "ssh";
      supportedFeatures = [
        "nixos-test"
        "benchmark"
        "big-parallel"
        "kvm"
      ];
      mandatoryFeatures = [ ];
    }
  ];

  nix.distributedBuilds = true;

  # Use x86_64 linux cross-compiled kernel.
  boot.kernelPackages = lib.mkForce (
    pkgsX86Cross.linux-asahi.override {
      _kernelPatches = config.boot.kernelPatches;
      withRust = config.hardware.asahi.withRust;
    }
  );
}
