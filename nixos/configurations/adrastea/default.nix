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
    services."code-server".default = {
      exe = "${pkgs.code-oss.rehweb}/bin/code-server-oss";
      socketPath = "$XDG_RUNTIME_DIR/code-default.socket";
    };
    services."code-server".fhs =
      let
        name = "vscode-env";
        fhs = pkgs.buildFHSEnv {
          inherit name;
          targetPkgs =
            pkgs:
            (with pkgs; [
              stdenv.cc
              perl
              python3
              cudatoolkit
              libGL
              glib
              zlib
              git
              openssh
            ])
            ++ [ config.boot.kernelPackages.nvidia_x11 ];
          runScript = pkgs.writeShellScript "code-oss-server.sh" ''
            ${pkgs.code-oss.rehweb}/bin/code-server-oss $@
          '';
        };
      in
      {
        exe = "${fhs}/bin/${name}";
        socketPath = "$XDG_RUNTIME_DIR/code.socket";
      };
  };

  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./networking.nix
    ./vm.nix
    ./wireguard.nix
    ./nvidia.nix
  ];

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

  environment.systemPackages =
    with pkgs.libsForQt5;
    [ ark ]
    ++ (with pkgs; [
      gnumake
      qemu
      virt-viewer

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
      cmake
      lldb
      llvmPackages_16.clang
      llvmPackages_16.bintools
      (hiPrio clang-tools_16)
      rr

      pciutils
      usbutils

      (python311.withPackages (
        ps: with ps; [
          numpy
          requests
          matplotlib
          scipy
        ]
      ))

      jdk17

      chromium

      libreoffice-qt

      # VNC client
      krdc

      # better frp
      rathole

      fluent-icon-theme

      nodejs
      yarn

      code-oss
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
    zxy = {
      isNormalUser = true;
      description = "Xiaoyu Zhang";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAChPZIziXRA0i7/A5Q5JuQf0rh2tfIuQ/lE7gxoxyUv zhang@hhh"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG6MKXjYOkBEo7Ex6qTczyxS/jbYekBOs7klT6l62v+f dell@DESKTOP-SI7T7BL"
      ] ++ config.users.users.lyc.openssh.authorizedKeys.keys;
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
