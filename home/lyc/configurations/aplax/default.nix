{ pkgs, config, ... }:
{
  programs.vscode.enable = true;

  home.homeDirectory = "/Users/${config.home.username}";

  programs.zsh.dirHashes = {
    flakes = "${config.home.homeDirectory}/flakes";
  };

  inclyc.ssh.ICTProxy = true;

  home.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
    (hiPrio clang-tools_16)
    (texlive.combine {
      inherit (texlive) scheme-full;
    })
    clash-meta
    pinentry_mac
    qemu
    telegram-desktop
  ];
}
