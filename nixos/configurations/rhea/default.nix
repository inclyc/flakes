{ modulesPath, pkgs, ... }:
{
  imports = [
    (modulesPath + "/installer/sd-card/sd-image-aarch64.nix")
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  nixpkgs.hostPlatform = "aarch64-linux";

  nixpkgs.overlays = [
    (final: super: {
      zfs = super.zfs.overrideAttrs (_: {
        meta.platforms = [ ];
      });
    })
  ];

  services.openssh = {
    enable = true;
    settings = {
      passwordAuthentication = false;
      kbdInteractiveAuthentication = false;
    };
  };

  networking.hostName = "rhea";

  networking.networkmanager.enable = true;

  inclyc.user.enable = true;


  system.stateVersion = "23.05";
}
