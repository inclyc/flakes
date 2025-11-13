{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.inclyc.gui;
in
{
  options.inclyc.gui = {
    enable = lib.mkEnableOption "enable GUI host";
  };

  config = lib.mkIf cfg.enable {
    programs.nix-ld.libraries =
      with pkgs;
      [
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
      ]
      ++ (with xorg; [
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
      enable = true;
      type = "fcitx5";
      fcitx5.addons = [ pkgs.qt6Packages.fcitx5-chinese-addons ];
      fcitx5.waylandFrontend = true;
    };

    services.greetd = {
      settings = rec {
        default_session = {
          command = "startplasma-wayland";
          user = "lyc";
        };
        initial_session = default_session;
      };
    };

    services.xserver.enable = true;

    services.displayManager.sddm.enable = true;
    services.displayManager.sddm.wayland.enable = true;
    services.desktopManager.plasma6.enable = true;

    # Enable CUPS to print documents.
    services.printing.enable = true;

    services.pulseaudio.enable = false;
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
      enableDefaultPackages = false;
      packages = with pkgs; [
        jetbrains-mono
        nerd-fonts.fira-code
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        noto-fonts-color-emoji
        source-sans-pro
        source-serif-pro
        corefonts
        vista-fonts
        vista-fonts-chs
        segoe-ui-variable
        segoe-ui
        simsun
      ];
      fontconfig.defaultFonts = pkgs.lib.mkForce {
        serif = [
          "Source Serif Pro"
          "Noto Serif CJK SC"
          "Noto Serif"
        ];
        sansSerif = [
          "Source Sans Pro"
          "Noto Sans CJK SC"
          "Noto Sans"
        ];
        monospace = [
          "FiraCode Nerd Font Mono"
          "JetBrains Mono"
        ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
