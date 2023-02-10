# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../common/global
    ];

  # boot.binfmt.emulatedSystems = [ "aarch64-linux" "riscv64-linux" ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "metis"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Hong_Kong";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "C.UTF-8";
    extraLocaleSettings = {
      LC_MESSAGES = "en_US.UTF-8";
      LC_TIME = "C.UTF-8";
      LC_CTYPE = "zh_CN.UTF-8";
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users = {
    lyc = {
      isNormalUser = true;
      description = "Yingchi Long";
      extraGroups = [ "networkmanager" "wheel" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEleFfCz0snjc4Leoi8Ad2KQykTopiJBy/ratqww7xhE"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOY+bJyD0pMB2YT+PU6bb9AkZJNeTckWrmewcgoWhPGL"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN3qIMkf0S9qfGN0c/ZsFeEqA2Q6ebdjrZMjGKcfPPdl"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOaTuhZmnqapIx6oMW1I0TCeocVAEhmNXELbIKmazdVR"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC6ezp2umiMwAo2+bOsdQnTRs+0Suv9b+hF63h/XPYZv"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJkYzGkwtGiync8npD5qTPT7fbgviw8dOL5LsrVpAMy3"
      ];
      shell = pkgs.zsh;
    };
    root.initialHashedPassword = "$6$VItBrOpGBXUZx19w$SnffROSfG69jHZkBhbqcScGEV2CpB52toTwpnZ/E3TJUxlaXv8/zGHRpFOefFfPwnfORC/aBrtTIRorxWKlzg/";
  };

  users.defaultUserShell = pkgs.zsh;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  programs = {
    neovim = {
      enable = true;
      vimAlias = true;
      viAlias = true;
    };
  };

  environment.shells = with pkgs; [ zsh ];
  environment.localBinInPath = true;

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      passwordAuthentication = false;
      kbdInteractiveAuthentication = false;
    };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
