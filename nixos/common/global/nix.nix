{ pkgs, inputs, lib, config, ... }:
{
  nix = {
    settings = {
      substituters = [
        "https://mirrors.bfsu.edu.cn/nix-channels/store"
        "https://nix-community.cachix.org"
      ];
      trusted-users = [ "root" "@wheel" ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
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
