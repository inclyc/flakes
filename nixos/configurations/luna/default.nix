{ lib, ... }:

{

  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  inclyc = {
    user.enable = true;
    user.zsh = true;
  };

  networking.dhcpcd.enable = false;
  networking.useDHCP = false;
  networking.useHostResolvConf = false;

  systemd.network.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "luna";

  time.timeZone = "Asia/Shanghai";

  systemd.network.networks = {
    "enp0s1" = {
      matchConfig.Name = "enp0s1";
      networkConfig = {
        DHCP = "ipv4";
        IPv6AcceptRA = true;
      };
    };
  };

  virtualisation.rosetta.enable = true;
  boot.binfmt.registrations.rosetta.preserveArgvZero = lib.mkForce true;

  services.openssh.enable = true;
  virtualisation.podman.enable = true;
  system.stateVersion = "25.05"; # Did you read the comment?

}
