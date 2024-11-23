{
  pkgs,
  config,
  lib,
  ...
}:
{

  imports = [ ./sops.nix ];

  inclyc.tex.enable = true;
  inclyc.ssh.ICTProxy = true;

  programs.vscode = {
    enable = true;
    userSettings = (builtins.fromJSON (builtins.readFile ./vscode-settings.json));
    extensions = with pkgs.vscode-extensions; [ vadimcn.vscode-lldb ];
  };

  services.gpg-agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-curses;
  };

  programs.zsh.dirHashes = {
    flakes = "${config.home.homeDirectory}/workspace/CS/OS/NixOS/flakes";
    llvm = "${config.home.homeDirectory}/workspace/CS/Compilers/llvm-project";
  };

  programs.ssh.matchBlocks."adrastea-zxy" = lib.mkForce {
    hostname = "localhost";
    user = "zxy";
    port = 22;
  };

  home.file.".ssh/config" = {
    target = ".ssh/config_source";
    onChange = ''cat .ssh/config_source > .ssh/config && chmod 400 .ssh/config'';
  };
}
