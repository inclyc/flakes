{ lib, config, ... }:
{
  home.sessionVariables = lib.mkIf (config.xdg.enable) {
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

  gtk.gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";

  xdg.enable = lib.mkDefault true;

  programs.gpg = lib.mkIf (config.xdg.enable) { homedir = "${config.xdg.dataHome}/gnupg"; };
}
