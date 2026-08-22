{
  pkgs,
  config,
  lib,
  ...
}:
{

  imports = [ ./sops.nix ];

  inclyc.development.android.enable = true;

  inclyc.tex.enable = true;
  inclyc.ssh.ICTProxy = true;

  systemd.user.tmpfiles.rules = [
    "d %h/Downloads - - - mM:7d"
  ];

  systemd.user.slices.agent = {
    Unit.Description = "Constrained agent tasks";
    Slice = {
      MemoryHigh = "28G";
      MemoryMax = "32G";
      MemorySwapMax = "4G";
      ManagedOOMMemoryPressure = "kill";
      ManagedOOMMemoryPressureLimit = "60%";
      ManagedOOMMemoryPressureDurationSec = "30s";
      ManagedOOMSwap = "kill";
    };
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

  programs.ssh.settings."adrastea-zxy" = lib.mkForce {
    HostName = "localhost";
    User = "zxy";
    Port = 22;
  };

  home.packages = with pkgs; [
    pnpm
  ];
}
