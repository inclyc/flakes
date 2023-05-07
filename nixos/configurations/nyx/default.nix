{ config, pkgs, ... }:
let
  chisel_need = (with pkgs; [
    jdk17_headless
    gnumake
    trashy
    mill
  ]);
  difftest_need = (with pkgs; [
    llvmPackages_15.llvm
    verilator
    readline
    ncurses
    gnumake
    bison
    flex
    fmt
    gcc
    gdb
  ]);
in
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  imports = [
    (fetchTarball "https://github.com/nix-community/nixos-vscode-server/tarball/master")
    <nixpkgs/nixos/modules/virtualisation/qemu-vm.nix>
    ./home.nix
  ];
  networking.hostName = "nyx";

  users.users = {
    admin = {
      isNormalUser = true;
      # Enable ‘sudo’ for the user.
      extraGroups = [ "wheel" ];
      packages = with pkgs; [
        neofetch
      ] ++ chisel_need ++ difftest_need;
      initialPassword = "nix";
    };
    chisel1 = {
      isNormalUser = true;
      packages = difftest_need ++ chisel_need;
      initialPassword = "nix";
    };
    chisel2 = {
      isNormalUser = true;
      packages = difftest_need ++ chisel_need;
      initialPassword = "nix";
    };
  };

  # virtualisation = {
  #   memorySize = 8192; # Use 8192MB memory.
  #   cores = 8; # Simulate 8 cores.
  #   diskSize = 4096; # Simulate 4G disk
  # };

  services = {
    openssh = {
      enable = true;
      port = [201020];
      settings = {
        passwordAuthentication = false;
        kbdInteractiveAuthentication = false;
      };
    };
    vscode-server.enable = true;
  };

  programs = {
    git.enable = true;
  };

  # Set your time zone.
  time.timeZone = "Asia/Hong_Kong";
  system.stateVersion = "22.11";
}
