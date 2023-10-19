{ pkgs, config, lib, ... }:
{
  services.kdeconnect.enable = true;

  programs.vscode = {
    enable = true;
    userSettings = (builtins.fromJSON (builtins.readFile ./vscode-settings.json));
  };

  programs.zsh.dirHashes = {
    flakes = "${config.home.homeDirectory}/workspace/flakes";
  };

  services.gpg-agent = {
    enable = true;
    extraConfig = ''
      pinentry-program ${pkgs.pinentry-curses}/bin/pinentry-curses
    '';
  };
}
