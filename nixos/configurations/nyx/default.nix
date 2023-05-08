{ config, pkgs, lib, inputs, ... }:
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
  networking.hostName = "nyx";
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  imports = [
    inputs.vscode-server.nixosModule
      # <nixpkgs/nixos/modules/virtualisation/qemu-vm.nix>
  ];

  # virtualisation = {
  #   memorySize = 2048; # Use 2048MiB memory.
  #   cores = 4; # Simulate 4 cores.
  # };

  users.users = {
    admin = {
      isNormalUser = true;
      # Enable ‘sudo’ for the user.
      extraGroups = [ "wheel" ];
      packages = with pkgs; [
        neofetch
      ] ++ chisel_need ++ difftest_need;
    };
    chisel1 = {
      isNormalUser = true;
      packages = difftest_need ++ chisel_need;
    };
    chisel2 = {
      isNormalUser = true;
      packages = difftest_need ++ chisel_need;
    };
  };

  services = {
    openssh = {
      enable = true;
      ports = [ 201020 ];
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
