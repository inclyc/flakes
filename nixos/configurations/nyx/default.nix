{ config, pkgs, lib, inputs, modulesPath, ... }:
let
  chisel_need = (with pkgs; [
    jdk17_headless
    gnumake
    trashy
    mill
  ]);
  difftest_need = (with pkgs; [
    llvmPackages_15.libllvm
    verilator
    readline
    ncurses
    bison
    flex
    fmt
    fd

    gnumake
    bison
    flex
    gcc
    gdb
  ]);
in
{
  networking.hostName = "nyx";
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  imports = [
    inputs.vscode-server.nixosModule
    ("${modulesPath}" + "/virtualisation/qemu-vm.nix")
  ];

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
    };
    chisel2 = {
      isNormalUser = true;
      packages = difftest_need ++ chisel_need;
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
    graphics = false;
    host.pkgs = inputs.nixpkgs.legacyPackages."x86_64-linux";
    qemu.package = config.virtualisation.host.pkgs.qemu; ## copy from enceladus fork, don't know why 
    forwardPorts = [
      { from = "host"; host.port = 20102; guest.port = 22; }
    ];
  };

  users.defaultUserShell = pkgs.zsh;
  programs = {
    git.enable = true;
    zsh = {
      enable = true;
      shellAliases = {
        ls = "ls --color";
        ll = "ls -l";
        l = "ls -CF";
        la = "ls -a";
        tp = "trash put";
      };
      enableCompletion = true;
      enableBashCompletion = true;
      syntaxHighlighting.enable = true;
      autosuggestions.enable = true;
    };
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
