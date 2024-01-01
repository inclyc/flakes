# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, config, lib, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./wireguard.nix
    inputs.nixos-apple-silicon.nixosModules.apple-silicon-support
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernel.sysctl = {
    "vm.swappiness" = 100;
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = "1";
  };

  networking.hostName = "aplaz"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  services.dae.enable = true;

  services.clash = {
    enable = true;
    rule.enable = true;
  };

  services.resolved.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  fileSystems = {
    "/".options = [ "compress=zstd" ];
    "/home".options = [ "compress=zstd" ];
    "/nix".options = [ "compress=zstd" "noatime" ];
  };


  systemd.oomd.enableRootSlice = true;
  systemd.oomd.enableUserServices = true;

  inclyc.gui.enable = true;
  inclyc.user.enable = true;
  inclyc.user.zsh = true;

  i18n = {
    defaultLocale = "C.UTF-8";
    extraLocaleSettings = {
      LC_MESSAGES = "en_US.UTF-8";
      LC_TIME = "C.UTF-8";
      LC_CTYPE = "zh_CN.UTF-8";
    };
  };

  zramSwap.enable = true;


  services.xserver.displayManager.sddm.settings = {
    General = {
      DisplayServer = "wayland";
      InputMethod = "";
    };
    Wayland = {
      CompositorCommand = "${pkgs.weston}/bin/weston --shell=fullscreen-shell.so";
    };
  };

  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It’s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

  environment.systemPackages = with pkgs; [
    gnumake
    qemu

    gdb
    file
    patchelf
    btop
    stdenv.cc

    valgrind
    kcachegrind

    sops
    age
    ssh-to-age

    vim
    neovim

    neofetch

    meson
    cmake
    lldb
    llvmPackages_16.clang
    llvmPackages_16.bintools
    rr
    ccache
    ninja
    (lib.meta.hiPrio clang-tools_16)

    python3

    man-pages
    man-pages-posix

    chromium

    libreoffice-qt
    bubblewrap
    tigervnc
  ];

  hardware.bluetooth.enable = true;

  security.pam.u2f = {
    enable = true;
    cue = true;
    authFile = pkgs.writeText "u2f_keys" ''
      lyc:4FV+6pMkst1elJXq+dbVIjapuEvIFkE+ts0mM11kSn1rzatMixRaf5oqiyPpjA/bm9T+pgypwETVQ+VOahX5vv////k=,z3zXcGMPB3UNyuHPPBb6q4LTJyOd5ZyN4KhhypiG5lMYvVOkrMbfQDJrZDO836EnoayPCNQDuoKvSU7kTTavmg==,es256,+presence
    '';
  };

  security.pam.services = {
    login.u2fAuth = true;
    sudo.u2fAuth = true;
  };

  services.xserver.displayManager.sddm.enable = lib.mkForce false;

  services.greetd.enable = true;

  virtualisation.podman.enable = true;

}

