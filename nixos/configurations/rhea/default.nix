{ pkgs, ... }:
{
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

  inclyc.user.enable = true;


  system.stateVersion = "23.05";
}
