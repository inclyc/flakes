{ config, ... }:
{
  boot.supportedFilesystems = [ "zfs" ];
  networking.hostId = "b33ddb24";
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;

  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.loader.efi.canTouchEfiVariables = false;

  services.zfs.autoSnapshot.enable = true;
}
