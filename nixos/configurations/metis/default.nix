{ pkgs
, lib
, ...
}:
{
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";


  # Proxmox-VE container, running LXC
  boot.isContainer = true;

  networking.hostName = "metis";

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
    inputMethod = {
      enabled = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-chinese-addons
      ];
    };
  };

  virtualisation.podman = {
    enable = true;

    # Create a `docker` alias for podman, to use it as a drop-in replacement
    dockerCompat = true;

    # Required for containers under podman-compose to be able to talk to each other.
    defaultNetwork.settings.dns_enabled = true;
  };

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
  programs.zsh.enable = true;

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
}
