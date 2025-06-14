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

  systemd.user.tmpfiles.rules = [
    "d %h/Downloads - - - mM:7d"
  ];

  systemd.user.services."tunnel-8A" = {
    Unit = {
      Description = "SSH Tunnel for Local Port Forwarding";
      After = [ "network.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.openssh}/bin/ssh -N -o ControlMaster=no -L 8008:localhost:8000 8A";
      Restart = "always";
      RestartSec = "5";
    };
    Install.WantedBy = [ "default.target" ];
  };

  programs.vscode = {
    enable = true;
    profiles.default.userSettings = (builtins.fromJSON (builtins.readFile ./vscode-settings.json));
  };

  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-curses;
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

  home.packages = with pkgs; [
    nodePackages.pnpm
  ];
}
