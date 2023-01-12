{ pkgs, inputs, lib, config, ... }:
{
  nix = {
    settings = {
      substituters = [
        "https://hyprland.cachix.org"
        "https://nix-community.cachix.org"
        "https://mirrors.bfsu.edu.cn/nix-channels/store"
      ];
      trusted-users = [ "root" "@wheel" ];
      auto-optimise-store = lib.mkDefault true;
      experimental-features = [ "nix-command" "flakes" "repl-flake" ];
      warn-dirty = false;
      system-features = [ "kvm" "big-parallel" ];
    };
    package = pkgs.nixUnstable;
    gc = {
      automatic = true;
      dates = "weekly";
    };
  };
}
