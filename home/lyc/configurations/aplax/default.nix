{
  inputs,
  pkgs,
  config,
  ...
}:
{
  programs.vscode = {
    enable = true;
    userSettings = {
      "editor.fontSize" = 15;
    };
  };

  home.homeDirectory = "/Users/${config.home.username}";

  programs.zsh.dirHashes = {
    flakes = "${config.home.homeDirectory}/flakes";
  };

  inclyc.ssh.ICTProxy = true;

  home.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
    (hiPrio clang-tools_16)
    (texlive.combine { inherit (texlive) scheme-full; })
    clash-meta
    pinentry_mac
    qemu
    telegram-desktop

    code-oss

    nodejs

    nixd
  ];

  home.sessionVariables = {
    NIX_PATH = "nixpkgs=${inputs.nixpkgs}";
  };

  programs.kitty.enable = true;
  programs.kitty.font = {
    name = "FiraCode Nerd Font Mono";
    size = 13;
  };
}
