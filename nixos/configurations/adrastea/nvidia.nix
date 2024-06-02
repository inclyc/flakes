{ config, ... }:
let
  kernelPackages = config.boot.kernelPackages;
  nvidia = kernelPackages.nvidia_x11;
in
{
  # Provides kernel pacakges
  boot.extraModulePackages = [ nvidia ];

  # Provides nvidia-smi
  environment.systemPackages = [ nvidia ];

  # Set "NVIDIA_KERNEL" for furthur references.
  environment.sessionVariables = { NVIDIA_KERNEL = nvidia; };
}
