{ modulesPath, pkgs, ... }:
{
  imports = [ (modulesPath + "/installer/sd-card/sd-image-aarch64.nix") ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  nixpkgs.hostPlatform = "aarch64-linux";

  nixpkgs.overlays = [
    (final: super: {
      zfs = super.zfs.overrideAttrs (_: {
        meta.platforms = [ ];
      });
    })
  ];

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  networking.hostName = "rhea";

  networking.networkmanager.enable = true;

  inclyc.user.enable = true;

  users.users.hgh = {
    isNormalUser = true;
    description = "Guanghui Hu";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDXqYq0LKuSGBNafT2/WrAhHtqBsu4He54V4o3oiOWyP1+mR8iJqHfvZAKGwtrv994ROAAE2GYeJoT46kTJGJkqL9DHfWtw8UbmjgQJLTl+h6LlhQWMuCoRzsjxV7N+bDiTK7vWA1hh2vb3JJHdoOmv7H+Wwitr8VRab8jGf2+FO8S4aJ287LGO8Cr0BschDDEmfXGqZ7X+cneV27FatUPIKCSaAY2X90pMZWHDrItz3Lc5ZvYsMKiyBMG3fkpbfBaki7YdtYgWXPyL2KxldmmZA/qm1WMLmcBc+2KukUluXzAzpwVnPjowIBajXSij76Lh4vqIoH0uBo10qAOmxZIZV8MdwyOH//2FBfWZ5d/ipAJbSxkk6a0Lxv+0vkvZ+zdLa8GkwQ2KQP6Y51Xj4Z9MdXm2GNQM7xd4TIzlEi1++74LfaPTZXp+BG+OyujS+nTruEOLJ5hzF7FU4ZEKuC3E3TBubRYY7Q1OoolvEa/bdp2No+r+FtVgANOucKdDb6c="
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQD+FPPG9a2AFyEHeH3M5YUHskObfmHu2jZCk8i1T86xUAIN4CQkBb1tEfIoTw/A8oWutCQlALz6NW2O5p84PNOdV23NEjd+qAPlTKSQuOB1O0fwPwoysu4n3P0w7r3hjaiExRnk+OLIi35Gl+V9ALrqjRwOHOZ/tFMyb6sXM6ZinVq0Zn+Un57b9FIUqoCaC/sb1kj9z73TS8AD0Lh45v1lFQHo7YV2OsqcUH8cUIoH98d+Hwg2ccSu1EXY1ETK063TkeEnX1AXzZIUS2V7mRuaXZB7h7Ln1dpe0ECuI1T1xAyyjdzZgYgk4zI/kKHqBlrGCTBmxy8sAKheNDeU6YMj3Ym97qKAxZCVghsRhaoFuFLAacIYY+xS6ck+ngTgTSgP0oGj7fx1n3ywmikdVbUywSySMYYFKim/RIl9EY5tujpXucrdNWUTGC6cwtokaaqvibNeTCR5uM2z8c7smyagzuS8HRTdCdW+XbrCuIVqXiDADQ3h1BLobxj0pqE7dzE="
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPVWQfblaorj5/4blfnDTFNl/fY5Xp8vBHDdSZriWZ2Q"
    ];
  };

  system.stateVersion = "23.05";
}
