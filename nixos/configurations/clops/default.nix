{
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "clops";

  networking.networkmanager.enable = true;

  services.xserver = {
    enable = true;
    desktopManager = {
      xterm.enable = false;
      xfce.enable = true;
    };
  };
  services.displayManager.defaultSession = "xfce";

  environment.systemPackages = with pkgs; [
    chromium
    pnpm
    git
  ];

  services.tailscale.enable = true;

  time.timeZone = "Asia/Hong_Kong";

  inclyc.user.enable = true;

  services.openssh.enable = true;
  networking.firewall.enable = false;

  system.stateVersion = "25.11";

}
