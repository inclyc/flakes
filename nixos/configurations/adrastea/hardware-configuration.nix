# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    {
      device = "tank/nixos/root";
      fsType = "zfs";
      options = [ "zfsutil" "X-mount.mkdir" ];
    };

  fileSystems."/nix" =
    {
      device = "tank/nixos/nix";
      fsType = "zfs";
      options = [ "zfsutil" "X-mount.mkdir" ];
    };

  fileSystems."/var" =
    {
      device = "tank/nixos/var";
      fsType = "zfs";
      options = [ "zfsutil" "X-mount.mkdir" ];
    };

  fileSystems."/var/lib" =
    {
      device = "tank/nixos/var/lib";
      fsType = "zfs";
      options = [ "zfsutil" "X-mount.mkdir" ];
    };

  fileSystems."/var/log" =
    {
      device = "tank/nixos/var/log";
      fsType = "zfs";
      options = [ "zfsutil" "X-mount.mkdir" ];
    };

  fileSystems."/srv" =
    {
      device = "tank/srv";
      fsType = "zfs";
      options = [ "zfsutil" "X-mount.mkdir" ];
    };

  fileSystems."/home" =
    {
      device = "tank/home";
      fsType = "zfs";
      options = [ "zfsutil" "X-mount.mkdir" ];
    };

  fileSystems."/boot" =
    {
      device = "boot";
      fsType = "zfs";
      options = [ "zfsutil" "X-mount.mkdir" ];
    };

  fileSystems."/srv/minecraft" =
    {
      device = "tank/srv/minecraft";
      fsType = "zfs";
      options = [ "zfsutil" "X-mount.mkdir" ];
    };

  fileSystems."/home/lyc/workspace" =
    {
      device = "tank/home/workspace";
      fsType = "zfs";
      options = [ "zfsutil" "X-mount.mkdir" ];
    };

  fileSystems."/boot/efi" =
    {
      device = "/dev/disk/by-uuid/2A68-25EA";
      fsType = "vfat";
    };

  fileSystems."/var/hdd_store" =
    {
      device = "/dev/disk/by-uuid/542425ca-baf4-427b-84d7-a9334eaa90d4";
      fsType = "ext4";
    };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp4s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
