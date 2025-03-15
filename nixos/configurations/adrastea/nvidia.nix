{ config, pkgs, ... }:
let
  kernelPackages = config.boot.kernelPackages;
  nvidia = kernelPackages.nvidia_x11;
in
{
  # Provides kernel pacakges
  boot.extraModulePackages = [ nvidia ];

  environment.systemPackages = with pkgs; [
    nvidia # Provides nvidia-smi
    cudatoolkit # nvcc & cuda libraries.
  ];

  # Set "NVIDIA_KERNEL" for furthur references.
  environment.sessionVariables = {
    NVIDIA_KERNEL = nvidia;
  };

  # Initialize nvidia gpu card using "nvidia-smi" in root.
  systemd.services."nvidia-init" = {
    description = "Initialize NVIDIA GPU";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${nvidia.bin}/bin/nvidia-smi";
    };

    wantedBy = [ "multi-user.target" ];
  };

  # Some NixOS vendored programs look up nvidia libraries under /run/opengl-drivers
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  programs.nix-ld.libraries = with pkgs; [
    cudatoolkit
    nvidia
  ];
}
