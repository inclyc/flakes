# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  pkgs,
  lib,
  config,
  ...
}:

{
  inclyc = {
    gui.enable = true;
    user = {
      enable = true;
      zsh = true;
      ssh = true;
    };
    development = {
      rust.enable = true;
      python.enable = true;
    };
  };

  imports = [
    ./game.nix
    ./gitea.nix
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./networking.nix
    ./nvidia.nix
    ./vm
    ./wireguard.nix
    ./llm.nix
    ./wxiat-proxy.nix
  ];

  specialisation = {
    nvidia.configuration = {
      inclyc.hardware.nvidia.enable = true;
    };
  };

  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
    "riscv64-linux"
  ];

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

  environment.systemPackages = with pkgs; [
    gnumake
    qemu

    gdb
    file
    patchelf
    btop
    stdenv.cc

    sops
    age
    ssh-to-age

    valgrind
    meson
    ninja
    cmake
    lldb
    llvmPackages_latest.clang
    llvmPackages_latest.bintools
    (hiPrio clang-tools_16)
    rr

    pciutils
    usbutils

    jdk

    chromium

    du-dust
    ripgrep
    fd

    # VNC client
    kdePackages.krdc

    nodejs
    yarn

    nixfmt-rfc-style

    (texlive.combine { inherit (texlive) scheme-full; })
    typst

    iverilog
    verilator
    verible

    racket
    chez

    nixd

    # Archive utilities.
    zip
    unzip
    rar
    unrar

    lean4
    elan

    esbuild

    wpsoffice-cn

    # Tencent apps
    (wechat-uos.override {
      buildFHSEnv =
        args:
        buildFHSEnv (
          args
          // {
            # bubble wrap wechat-uos's home directory
            extraPreBwrapCmds = ''
              mkdir -p "''${XDG_DATA_HOME:-$HOME/.local/share}/wechat-uos"
            '';
            extraBwrapArgs = [
              "--bind \"\${XDG_DATA_HOME:-$HOME/.local/share}/wechat-uos\" \"$HOME\""
              # Bind "Downloads", "Pictures" directory to home directory
              "--bind \"\${XDG_DOWNLOAD_DIR:-$HOME/Downloads}\" \"$HOME/Downloads\""
              "--bind \"\${XDG_PICTURES_DIR:-$HOME/Pictures}\" \"$HOME/Pictures\""
              "--chdir \"$HOME\""
            ];

            unshareUser = true;
            unshareIpc = true;
            unsharePid = true;
            unshareNet = false;
            unshareUts = true;
            unshareCgroup = true;
            privateTmp = true;
          }
        );
    })
    qq

    uv

    git-branch-clean
  ];

  virtualisation.spiceUSBRedirection.enable = true;

  virtualisation.waydroid.enable = true;

  # Grant non-privileged users to access USB devices
  # For rootlesss USB forwarding (without SPICE)
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", GROUP="users", MODE="0660"
    SUBSYSTEM=="usb_device", GROUP="users", MODE="0660"

    SUBSYSTEM=="vfio", GROUP="wheel", MODE="0660"
    SUBSYSTEM=="input", GROUP="wheel", MODE="0660"
  '';

  security.pam.loginLimits = [
    {
      domain = "@wheel";
      item = "memlock";
      type = "hard";
      value = "unlimited";
    }
    {
      domain = "@wheel";
      item = "memlock";
      type = "soft";
      value = "unlimited";
    }
  ];

  nixpkgs.config.permittedInsecurePackages = [ "electron-19.0.7" ];

  services.greetd.enable = false;

  # Workaround of nixpkgs#187963 and nixpkgs#199881
  services.xserver.displayManager.setupCommands = lib.mkForce "";

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
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

  security.pam.u2f.settings = {
    enable = true;
    cue = true;
    authFile = pkgs.writeText "u2f_keys" ''
      lyc:C0V54BSOmQQKAA1viuQx4qsQs2WdQhOIxrXiny/LUjZGYakFilKeZG0mJwl4lfLwfZr681jJ7dQSRh8WPm/8dP////k=,aCqQlCY+XOJzHHisvlMf4lZi7shNO6ARRuBsHoFzDpEB+p3pPMsIGEVYMLql/KWn0fV+l/uhAgqkPJ73F8y59w==,es256,+presence
    '';
  };

  users.users = {
    lyc = {
      uid = 1000;
      linger = true;
    };
    zxy = {
      isNormalUser = true;
      uid = 1001;
      description = "Xiaoyu Zhang";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAChPZIziXRA0i7/A5Q5JuQf0rh2tfIuQ/lE7gxoxyUv zhang@hhh"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG6MKXjYOkBEo7Ex6qTczyxS/jbYekBOs7klT6l62v+f dell@DESKTOP-SI7T7BL"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC1kJQp6apa/oxvdOr7+bmwLzM9nrXGrQVqnA6MFE+1k zxy@MacbookAir"
      ] ++ config.users.users.lyc.openssh.authorizedKeys.keys;
      linger = true;
    };
  };

  security.pam.services = {
    login.u2fAuth = true;
    sudo.u2fAuth = true;
  };

  services.snapper =
    let
      common = {
        TIMELINE_CLEANUP = true;
        TIMELINE_CREATE = true;
        TIMELINE_LIMIT_HOURLY = 3;
        TIMELINE_LIMIT_DAILY = 3;
        TIMELINE_LIMIT_WEEKLY = 2;
        TIMELINE_LIMIT_MONTHLY = 2;
        TIMELINE_LIMIT_YEARLY = 2;
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
