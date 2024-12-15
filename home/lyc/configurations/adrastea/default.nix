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

  systemd.user.services."code-server-fhs" = {
    Service = {
      ExecStart = "${pkgs.writeScript "start-code-server" ''
        #!${lib.getExe pkgs.linux-fhs-python}
        ${builtins.readFile ./start-code-server.py}
      ''}";
      Environment = [
        "CODIUM_REH=${pkgs.codium-reh}"
        "PORT=47562"
      ];
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

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
}
