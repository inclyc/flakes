{
  lib,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "sd_mod"
    "sr_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/9c86899f-25a9-46cd-858f-d6c8a3c82329";
    fsType = "btrfs";
    options = [ "subvol=root,compress=zstd" ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/9c86899f-25a9-46cd-858f-d6c8a3c82329";
    fsType = "btrfs";
    options = [ "subvol=home,compress=zstd" ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/9c86899f-25a9-46cd-858f-d6c8a3c82329";
    fsType = "btrfs";
    options = [ "subvol=nix,compress=zstd" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/1BC2-B14F";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
