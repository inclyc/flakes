{ modulesPath
, lib
, inputs
, config
, ...
}:
{

  imports = [
    ("${modulesPath}" + "/virtualisation/qemu-vm.nix")
  ];

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  inclyc.user.enable = true;

  services.getty.autologinUser = "root";

  virtualisation = {
    host.pkgs = inputs.nixpkgs.legacyPackages."x86_64-linux";
    qemu.package = config.virtualisation.host.pkgs.qemu;
    cores = 16;
    memorySize = 4096;
    graphics = false;
  };

  networking.hostName = "enceladus";

  virtualisation.forwardPorts = [
    { from = "host"; host.port = 20101; guest.port = 22; }
  ];

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
