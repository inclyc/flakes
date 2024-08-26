/**
  Game-specific configuration.
*/
{ pkgs, ... }:
{
  hardware.graphics.enable32Bit = true;

  environment.systemPackages = with pkgs; [
    wineWowPackages.stableFull
    winetricks
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };
}
