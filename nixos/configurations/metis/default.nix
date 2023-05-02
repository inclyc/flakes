{ pkgs
, lib
, ...
}:
{
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  inclyc.user.enable = true;
  inclyc.user.zsh = true;

  # Proxmox-VE container, running LXC
  boot.isContainer = true;

  networking.hostName = "metis";

  networking.interfaces.eth0.ipv4.addresses = [{
    address = "192.168.31.6";
    prefixLength = 24;
  }];

  networking.defaultGateway = "192.168.31.1";
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];

  # Set your time zone.
  time.timeZone = "Asia/Hong_Kong";


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
      passwordAuthentication = false;
      kbdInteractiveAuthentication = false;
    };
  };

  networking.firewall.enable = false;

  system.stateVersion = "22.11";
}
