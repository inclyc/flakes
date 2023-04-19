{ config, ... }:
{
  boot.supportedFilesystems = [ "zfs" ];
  networking.hostId = "b33ddb24";
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;

  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.generationsDir.copyKernels = true;
  boot.loader.grub = {
    efiInstallAsRemovable = true;
    enable = true;
    version = 2;
    copyKernels = true;
    efiSupport = true;
    zfsSupport = true;
    extraPrepareConfig = ''
      mkdir -p /boot/efi
      mount /boot/efi
    '';
    device = "nodev";
  };
  services.zfs.autoSnapshot.enable = true;
}
