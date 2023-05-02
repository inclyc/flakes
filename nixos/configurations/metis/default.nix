{ pkgs
, lib
, ...
}:
{
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  inclyc.user.enable = true;

  # Proxmox-VE container, running LXC
  boot.isContainer = true;

  networking.hostName = "metis";

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
