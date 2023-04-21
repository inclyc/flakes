# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./zfs.nix
      ./sops.nix
    ];

  boot.binfmt.emulatedSystems = [ "aarch64-linux" "riscv64-linux" ];

  networking.hostName = "adrastea"; # Define your hostname.
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
    inputMethod = {
      enabled = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-chinese-addons
      ];
    };
  };
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  environment.systemPackages = with pkgs.libsForQt5; [
    ark
  ] ++ (with pkgs; [
    musescore
    gnumake
    virt-manager
  ]);

  nixpkgs.config.permittedInsecurePackages = [
    "electron-19.0.7"
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  # Workaround of nixpkgs#187963 and nixpkgs#199881
  services.xserver.displayManager.setupCommands = lib.mkForce "";

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # virtualisation.virtualbox.host.enableExtensionPack = true;
  # virtualisation.virtualbox.host.enable = true;
  # users.extraGroups.vboxusers.members = [ "lyc" ];

  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true;
  users.extraGroups.libvirtd.members = [ "lyc" ];

  virtualisation.podman = {
    enable = true;

    # Create a `docker` alias for podman, to use it as a drop-in replacement
    dockerCompat = true;

    # Required for containers under podman-compose to be able to talk to each other.
    defaultNetwork.settings.dns_enabled = true;
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  hardware.opengl.extraPackages = [ pkgs.intel-compute-runtime ];
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

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
  programs.zsh.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  programs = {
    neovim = {
      enable = true;
      vimAlias = true;
      viAlias = true;
    };
    kdeconnect.enable = true;
  };

  fonts = {
    enableDefaultFonts = false;
    fonts = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-emoji
      jetbrains-mono
      fira-code
      (nerdfonts.override { fonts = [ "JetBrainsMono" "Noto" "FiraCode" ]; })
    ];
    fontconfig.defaultFonts = pkgs.lib.mkForce {
      serif = [ "Noto Serif CJK SC Bold" "Noto Serif" ];
      sansSerif = [ "Noto Sans CJK SC Bold" "Noto Sans" ];
      monospace = [ "FiraCode Nerd Font Mono" "JetBrains Mono" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  environment.shells = with pkgs; [ zsh ];
  environment.localBinInPath = true;

  boot.tmp.useTmpfs = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      passwordAuthentication = false;
      kbdInteractiveAuthentication = false;
    };
  };

  sops.secrets."ddns/cloudflare" = { };
  services.ddns."cloudflare" = {
    ipv4 = "adrastea.lyc.dev";
    index4 = "shell:curl -4L lug.hit.edu.cn/myip";
    dns = "cloudflare";
    extraPath = [ pkgs.curl ];
    environmentFile = [ config.sops.secrets."ddns/cloudflare".path ];
    onCalendar = "minutely";
  };

  sops.secrets."ddns/dnspod" = { };
  services.ddns."inclyc-cn" = {
    ipv4 = "ppp.ws.inclyc.cn";
    index4 = "shell:curl -4L lug.hit.edu.cn/myip";
    dns = "dnspod";
    extraPath = [ pkgs.curl ];
    environmentFile = [ config.sops.secrets."ddns/dnspod".path ];
    onCalendar = "minutely";
  };

  systemd.extraConfig = ''
    DefaultTimeoutStopSec=10s
  '';

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
