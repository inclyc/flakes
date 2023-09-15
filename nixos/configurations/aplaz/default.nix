# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, config, lib, pkgs, rootPath, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    inputs.sops-nix.nixosModules.sops
    inputs.nixos-apple-silicon.nixosModules.apple-silicon-support
  ];

  services.clash = {
    enable = true;
    workingDirectory = "/home/lyc/.local/share/clash";
  };

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
    meson
    cmake
    lldb
    llvmPackages_15.clang
    llvmPackages_15.bintools
    rr
    ccache
    ninja
    (lib.meta.hiPrio clang-tools_16)

    python3

    man-pages
    man-pages-posix

    chromium
  ];

  hardware.bluetooth.enable = true;

  sops.defaultSopsFile = rootPath + /secrets/general.yaml;

  sops.secrets."wireguard/aplaz" = { };

  networking.wireguard.interfaces = {
    # "wg0" is the network interface name. You can name the interface arbitrarily.
    wg0 = {
      # Determines the IP address and subnet of the client's end of the tunnel interface.
      ips = [ "10.131.0.2/24" ];

      # Path to the private key file.
      #
      # Note: The private key can also be included inline via the privateKey option,
      # but this makes the private key world-readable; thus, using privateKeyFile is
      # recommended.
      privateKeyFile = config.sops.secrets."wireguard/aplaz".path;

      peers = [
        # For a client configuration, one peer entry for the server will suffice.

        {
          # Public key of the server (not a file path).
          publicKey = "N/C9sVw5AbDdXQ9Kh/B1pCK0vYI8ugYo1ggbKG3+Nwo=";

          # Forward all the traffic via VPN.
          allowedIPs = [ "10.131.0.0/24" ];
          # Or forward only particular subnets
          #allowedIPs = [ "10.100.0.1" "91.108.12.0/22" ];

          # Set this to the server IP and port.
          endpoint = "llvmws.lyc.dev:20123"; # ToDo: route to endpoint not automatically configured https://wiki.archlinux.org/index.php/WireGuard#Loop_routing https://discourse.nixos.org/t/solved-minimal-firewall-setup-for-wireguard-client/7577

          # Send keepalives every 25 seconds. Important to keep NAT tables alive.
          persistentKeepalive = 25;
        }
      ];
    };
  };

}

