{ config
, pkgs
, lib
, inputs
, ...
}:
{
  imports = [
    ./wireguard.nix
  ];
  nixpkgs.hostPlatform = "x86_64-linux";
  nix.registry.sys = {
    from = { type = "indirect"; id = "sys"; };
    flake = inputs.nixpkgs-stable;
  };

  nix.settings.extra-platforms = [ "aarch64-linux" ];

  services.clash = {
    enable = true;
    rule.enable = true;
    rule.enableTUN = true;
  };

  inclyc.user.enable = true;
  inclyc.user.zsh = true;

  # Proxmox-VE container, running LXC
  boot.isContainer = true;

  networking.hostName = "metis";

  networking.dhcpcd.enable = false;
  networking.useDHCP = false;
  networking.useHostResolvConf = false;

  systemd.network.enable = true;

  systemd.network.networks = {
    "20-eth0@if72" = {
      matchConfig.Name = "eth0@if72";
      networkConfig = {
        DHCP = "no";
        Address = "192.168.31.6/24";
        Gateway = "192.168.31.1";
        DNS = "159.226.39.1";
      };
    };
  };

  # Set your time zone.
  time.timeZone = "Asia/Hong_Kong";

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

    unzip
    bubblewrap

    vim


    valgrind
    meson
    cmake
    lldb
    llvmPackages_16.clang
    llvmPackages_16.bintools
    rr
    ccache
    ninja
    (lib.meta.hiPrio clang-tools_16)

    pciutils
    usbutils

    python3

    mtr
    dig
  ];


  virtualisation.podman = {
    enable = true;

    # Create a `docker` alias for podman, to use it as a drop-in replacement
    dockerCompat = true;

    # Required for containers under podman-compose to be able to talk to each other.
    defaultNetwork.settings.dns_enabled = true;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  networking.firewall.enable = false;

  system.stateVersion = "22.11";
  users.users = {
    lt = {
      isNormalUser = true;
      description = "Teng Luo";
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDN9GBQmYO06ccXxYqKkn7r6PhHr5vHKsMOf9CYOF7225c3HkBSOYGWI+eaxFbch3GSSIS2YkdGJIfsLStfwoY4v2s9BJDUdLmPrwiLVYBOONeh5GrgAU7ETIicKAQM8V7nC6nJYqAf5Kin05MNjHhKP11JQH5AO+Lf7SE92GW0knuLRb9EW9HLtTUOqFU5xi9/2JZsV2dlyDSohFanABv1YbIPa3VLBug56krcy+it2Fm7ji/rRFRpy9FZOkPsmxz7X00VQuNAUPCQnmh6L0IL2ktpCM99TEaSalYiRX134wYXy//L6xM3Jp4/Ng5KxVdq2bLrSjy3c93PkdSAhxNdoOeb8q6Kw2dP3g4gwgNZDGc8tAEIEiTgw7rYKRTeFeJIrKXQs8O3QQpKBEoKtn8cMgZhapwqrfYZdQNDu+xWF6/Us3/6pDTBRn+sWGPcPzBu4nOwBf3KcYXYynz3MxXdtAftMHDmsiQ6GCxTUunjS2Cf9x/Mp43OPuLJVglzEKM= 86177@DESKTOP-FBIB3T0"
      ];
    };

    hgh = {
      isNormalUser = true;
      description = "Guanghui Hu";
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDXqYq0LKuSGBNafT2/WrAhHtqBsu4He54V4o3oiOWyP1+mR8iJqHfvZAKGwtrv994ROAAE2GYeJoT46kTJGJkqL9DHfWtw8UbmjgQJLTl+h6LlhQWMuCoRzsjxV7N+bDiTK7vWA1hh2vb3JJHdoOmv7H+Wwitr8VRab8jGf2+FO8S4aJ287LGO8Cr0BschDDEmfXGqZ7X+cneV27FatUPIKCSaAY2X90pMZWHDrItz3Lc5ZvYsMKiyBMG3fkpbfBaki7YdtYgWXPyL2KxldmmZA/qm1WMLmcBc+2KukUluXzAzpwVnPjowIBajXSij76Lh4vqIoH0uBo10qAOmxZIZV8MdwyOH//2FBfWZ5d/ipAJbSxkk6a0Lxv+0vkvZ+zdLa8GkwQ2KQP6Y51Xj4Z9MdXm2GNQM7xd4TIzlEi1++74LfaPTZXp+BG+OyujS+nTruEOLJ5hzF7FU4ZEKuC3E3TBubRYY7Q1OoolvEa/bdp2No+r+FtVgANOucKdDb6c="
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQD+FPPG9a2AFyEHeH3M5YUHskObfmHu2jZCk8i1T86xUAIN4CQkBb1tEfIoTw/A8oWutCQlALz6NW2O5p84PNOdV23NEjd+qAPlTKSQuOB1O0fwPwoysu4n3P0w7r3hjaiExRnk+OLIi35Gl+V9ALrqjRwOHOZ/tFMyb6sXM6ZinVq0Zn+Un57b9FIUqoCaC/sb1kj9z73TS8AD0Lh45v1lFQHo7YV2OsqcUH8cUIoH98d+Hwg2ccSu1EXY1ETK063TkeEnX1AXzZIUS2V7mRuaXZB7h7Ln1dpe0ECuI1T1xAyyjdzZgYgk4zI/kKHqBlrGCTBmxy8sAKheNDeU6YMj3Ym97qKAxZCVghsRhaoFuFLAacIYY+xS6ck+ngTgTSgP0oGj7fx1n3ywmikdVbUywSySMYYFKim/RIl9EY5tujpXucrdNWUTGC6cwtokaaqvibNeTCR5uM2z8c7smyagzuS8HRTdCdW+XbrCuIVqXiDADQ3h1BLobxj0pqE7dzE="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPVWQfblaorj5/4blfnDTFNl/fY5Xp8vBHDdSZriWZ2Q"
      ];
    };

    xyf = {
      isNormalUser = true;
      description = "Yifu Xu";
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCf3S1BlWQP5j080Mxq+fCUsR8Eo3ongI9USS2I+8EN5eIxGBgl3owDqCnw/PJQmTcZWm16qWTVrIQ7IjZXtV/qqOpl/8XnvucrKYX/yK19qQly/a7xWTHpRc1uRGnYOvpaUkKaGZrBVVgeGrFBV9uOv7wiqc15q3AKvo9ZQPzEDgqkuF833LBl+EfqQzakwRGO2m7gpkxw8WezH3rgMt6Dg2PyHItBMk38QocoB8AvRUGGe2kJpVvlzmcyjpbABV4P/IMqgasKVRz7HBicTz5JT18b9Ul3km8FGxvXYFCotiK1iyO6eYaU7lO1yCE37gekVcY7QJDDgChvTwuKkPJC4wS4QuGrBZB2YZhfF9ZrRycs8ICF0qvMGs5rAW1uHfhyKRR05ip8V9ypj7EuPgIQ82GqvCtqn9asORxYySp6Y7N1zwgw3nYy9LrwCL0iLsEZOjAvmBKKn8q00OIb1Q87sMkSUNz0WSWYReOueh24z578LMi5UbsSymOiluouj38= 1972088768@qq.com"
      ];
    };

    origami = {
      isNormalUser = true;
      description = "Origami404";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAZxRoweHoLfoaydPqhsLnc4EGgwTp7Uz1DZ2DG447B+"
      ];
    };
  };
}
