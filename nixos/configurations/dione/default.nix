{ modulesPath
, lib
, inputs
, config
, pkgs
, ...
}:
{

  imports = [
    ("${modulesPath}" + "/virtualisation/qemu-vm.nix")
  ];

  nixpkgs.hostPlatform = lib.mkDefault "riscv64-linux";
  nixpkgs.buildPlatform = "x86_64-linux";

  boot.loader.grub.enable = false;

  system.build.installBootLoader = lib.mkDefault "${pkgs.coreutils}/bin/true";


  inclyc.user.enable = true;

  services.getty.autologinUser = "root";

  virtualisation = {
    host.pkgs = inputs.nixpkgs.legacyPackages."x86_64-linux";
    qemu.package = config.virtualisation.host.pkgs.qemu;
    cores = 16;
    memorySize = 4096;
    graphics = false;
  };

  networking.hostName = "dione";

  # Set your time zone.
  time.timeZone = "Asia/Hong_Kong";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  services.openssh = {
    enable = true;
    settings = {
      passwordAuthentication = false;
      kbdInteractiveAuthentication = false;
    };
  };

  networking.firewall.enable = false;

  system.stateVersion = "22.11";

  programs.nix-ld.enable = lib.mkForce false;
}
