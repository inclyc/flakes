{ config
, lib
, pkgs
, ...
}:

with lib;
let
  cfg = config.inclyc.gui;
in
{
  options.inclyc.gui = {
    enable = mkEnableOption "enable GUI host";
  };

  config = mkIf cfg.enable {
    programs.nix-ld.libraries = with pkgs; [
      alsa-lib
      at-spi2-atk
      at-spi2-core
      atk
      cairo
      cups
      fontconfig
      freetype
      gdk-pixbuf
      glib
      gtk3
      libGL
      libappindicator-gtk3
      libdrm
      libnotify
      libpulseaudio
      pango
      pipewire
      mesa
    ] ++ (with xorg; [
      libX11
      libXScrnSaver
      libXcomposite
      libXcursor
      libXdamage
      libXext
      libXfixes
      libXi
      libXrandr
      libXrender
      libXtst
      libxkbfile
      libxshmfence
      libxcb
      libxkbcommon
      nspr
    ]);
    i18n.inputMethod = {
      enabled = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-chinese-addons
      ];
    };

    services.xserver.enable = true;

    services.xserver.displayManager.sddm.enable = true;
    services.xserver.desktopManager.plasma5.enable = true;

    # Enable CUPS to print documents.
    services.printing.enable = true;

    # Enable sound with pipewire.
    sound.enable = true;
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };

    fonts = {
      enableDefaultFonts = false;
      fonts = with pkgs; [
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        noto-fonts-emoji
        jetbrains-mono
        fira-code
        (nerdfonts.override { fonts = [ "JetBrainsMono" "Noto" "FiraCode" ]; })
      ];
      fontconfig.defaultFonts = pkgs.lib.mkForce {
        serif = [ "Noto Serif CJK SC Bold" "Noto Serif" ];
        sansSerif = [ "Noto Sans CJK SC Bold" "Noto Sans" ];
        monospace = [ "FiraCode Nerd Font Mono" "JetBrains Mono" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
