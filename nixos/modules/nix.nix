{ pkgs, inputs, lib, ... }:
{
  nix = {
    nixPath = [
      "nixpkgs=${inputs.nixpkgs}"
    ];
    settings = {
      substituters = [
        "https://mirrors.bfsu.edu.cn/nix-channels/store"
        "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
        "https://mirrors.ustc.edu.cn/nix-channels/store"
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://inclyc.cachix.org"
      ];
      trusted-users = [ "root" "@wheel" ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "inclyc.cachix.org-1:izGZ+f/JLPovKX1OKd3rQZ8nPOCpvPij3+bebjxdZ2k="
      ];
      auto-optimise-store = lib.mkDefault true;
      experimental-features = [ "nix-command" "flakes" "repl-flake" ];
      warn-dirty = false;
      system-features = [ "kvm" "big-parallel" ];
      use-xdg-base-directories = true;
    };
    package = pkgs.nixUnstable;
    gc = {
      automatic = true;
      dates = "weekly";
    };
    registry.sys = lib.mkDefault {
      from = { type = "indirect"; id = "sys"; };
      flake = inputs.nixpkgs;
    };
  };
}
