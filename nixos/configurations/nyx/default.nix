{ config, pkgs, lib, inputs, modulesPath, ... }:
{
  networking.hostName = "nyx";
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  imports = [
    inputs.vscode-server.nixosModule
    ("${modulesPath}" + "/virtualisation/qemu-vm.nix")
  ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  environment.defaultPackages = with pkgs; [
    jdk17_headless
    gnumake
    trashy
    mill
  ];

  users.users = {
    admin = {
      isNormalUser = true;
      # Enable ‘sudo’ for the user.
      extraGroups = [ "wheel" ];
      packages = with pkgs; [
        neofetch
      ];
      initialPassword = "nix";
    };
    chisel1 = {
      isNormalUser = true;
    };
    chisel2 = {
      isNormalUser = true;
    };
  };

  services = {
    openssh = {
      enable = true;
      ports = [ 22 ];
      settings = {
        passwordAuthentication = false;
        kbdInteractiveAuthentication = false;
      };
    };
    vscode-server.enable = true;
  };

  virtualisation = {
    cores = 16; ## modify by lyc's judgment
    memorySize = 4096; ## modify by lyc's judgment
    diskSize = 8192; ## modify by lyc's judgment
    graphics = false;
    host.pkgs = inputs.nixpkgs.legacyPackages."x86_64-linux";
    qemu.package = config.virtualisation.host.pkgs.qemu; ## copy from enceladus fork, don't know why 
    forwardPorts = [
      { from = "host"; host.port = 20102; guest.port = 22; }
    ];
  };

  programs = {
    git.enable = true;
    neovim = {
      enable = true;
      vimAlias = true;
      viAlias = true;
    };
  };

  # Set your time zone.
  time.timeZone = "Asia/Hong_Kong";
  system.stateVersion = "22.11";
}
