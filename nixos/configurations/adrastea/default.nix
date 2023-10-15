# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, inputs, ... }:

{
  inclyc = {
    gui.enable = true;
    user = {
      enable = true;
      zsh = true;
      ssh = true;
    };
    tailscale.enable = true;
  };

  imports = [
    inputs.sops-nix.nixosModules.sops
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./sops.nix
    ./networking.nix
    ./vm.nix
  ];

  boot.binfmt.emulatedSystems = [ "aarch64-linux" "riscv64-linux" ];

  networking.hostName = "adrastea"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Set your time zone.
  time.timeZone = "Asia/Hong_Kong";

  boot.kernel.sysctl."kernel.perf_event_paranoid" = -1;
  boot.kernel.sysctl."kernel.kptr_restrict" = lib.mkForce 0;

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "C.UTF-8";
    extraLocaleSettings = {
      LC_MESSAGES = "en_US.UTF-8";
      LC_TIME = "C.UTF-8";
      LC_CTYPE = "zh_CN.UTF-8";
    };
  };

  environment.systemPackages = with pkgs.libsForQt5; [
    ark
  ] ++ (with pkgs; [
    musescore
    gnumake
    qemu
    virt-viewer
    config.nur.repos.linyinfeng.wemeet

    gdb
    file
    patchelf
    btop
    stdenv.cc

    valgrind
    meson
    cmake
    lldb
    llvmPackages_15.clang
    llvmPackages_15.bintools
    (lib.meta.hiPrio clang-tools_15)
    rr
    ccache

    pciutils
    usbutils

    python3


    jdk17


    chromium

    # For VPN "Easyconnect"
    bubblewrap
    tigervnc

    libreoffice-qt
  ]);

  virtualisation.spiceUSBRedirection.enable = true;


  # Grant non-privileged users to access USB devices
  # For rootlesss USB forwarding (without SPICE)
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", GROUP="users", MODE="0660"
    SUBSYSTEM=="usb_device", GROUP="users", MODE="0660"

    SUBSYSTEM=="vfio", GROUP="wheel", MODE="0660"
    SUBSYSTEM=="input", GROUP="wheel", MODE="0660"
  '';

  security.pam.loginLimits = [
    { domain = "@wheel"; item = "memlock"; type = "hard"; value = "unlimited"; }
    { domain = "@wheel"; item = "memlock"; type = "soft"; value = "unlimited"; }
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "electron-19.0.7"
  ];


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

  virtualisation.podman = {
    enable = true;

    # Create a `docker` alias for podman, to use it as a drop-in replacement
    dockerCompat = true;

    # Required for containers under podman-compose to be able to talk to each other.
    defaultNetwork.settings.dns_enabled = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

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
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
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
  systemd.user.extraConfig = ''
    DefaultTimeoutStopSec=10s
  '';

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  services.snapper =
    let
      common = {
        TIMELINE_CLEANUP = true;
        TIMELINE_CREATE = true;
      };
      mkTimeline = a: a // common;
    in
    {
      configs = {
        home = mkTimeline { SUBVOLUME = "/home"; };
        root = mkTimeline { SUBVOLUME = "/"; };
      };
    };
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
