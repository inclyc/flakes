{ inputs, lib, pkgs, config, outputs, ... }:
{

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
  };

  nix = {
    package = lib.mkDefault pkgs.nix;
    settings = {
      substituters = [
        "https://mirrors.bfsu.edu.cn/nix-channels/store"
        "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
        "https://mirrors.ustc.edu.cn/nix-channels/store"
        "https://mirrors.cnnic.cn/nix-channels/store"
        "https://mirror.sjtu.edu.cn/nix-channels/store"
        "https://nix-community.cachix.org"
        "https://cache.nixos.org"
      ];
      trusted-users = [ "root" "@wheel" ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
      auto-optimise-store = lib.mkDefault true;
      experimental-features = [ "nix-command" "flakes" "repl-flake" ];
      warn-dirty = false;
    };
    registry.home = {
      from = { type = "indirect"; id = "home"; };
      flake = inputs.nixpkgs;
    };
  };

  home = {
    username = lib.mkDefault "lyc";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    stateVersion = lib.mkDefault "22.11";
    sessionVariables = {
      PYTHONHISTFILE = "${config.xdg.dataHome}/python_history";
      GTK_RC_FILES = "${config.xdg.configHome}/gtk-1.0/gtkrc";
      GTK2_RC_FILES = "${config.xdg.configHome}/gtk-2.0/gtkrc";
      CONDARC = "${config.xdg.configHome}/conda/condarc";
      WGETRC = "${config.xdg.configHome}/wgetrc";
      npm_config_userconfig = "${config.xdg.configHome}/npm/config";
      npm_config_cache = "${config.xdg.cacheHome}/npm";
      npm_config_prefix = "${config.xdg.dataHome}/npm";
      CARGO_HOME = "${config.xdg.dataHome}/cargo";
      _JAVA_OPTIONS = "-Djavafx.cachedir=${config.xdg.cacheHome}/openjfx -Djava.util.prefs.userRoot=${config.xdg.configHome}/java";
      GRADLE_USER_HOME = "${config.xdg.dataHome}/gradle";
      RUSTUP_HOME = "${config.xdg.dataHome}/rustup";
    };
    packages = with pkgs; [
      tree
      nix-index
      nix-output-monitor
      nix-tree
      python3
      htop

      # C/C++ build system
      cmake
      meson
      bear
    ];
  };

  xdg.enable = lib.mkDefault true;

  programs.home-manager.enable = true;
}
