{ pkgs, config, ... }:
{
  services.kdeconnect.enable = true;

  programs.vscode = {
    enable = true;
    userSettings = (builtins.fromJSON (builtins.readFile ./vscode-settings.json));
  };

  programs.zsh.dirHashes = {
    flakes = "${config.home.homeDirectory}/workspace/flakes";
  };
}
