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
    nerd-fonts.fira-code
    (texlive.combine { inherit (texlive) scheme-full; })
    clash-meta
    pinentry_mac
    qemu

    ollama

    nodejs
    yarn
    nodePackages.pnpm

    meson
    ninja

    nixd

    poetry

    pandoc

    elan

    rsync

    # Resources monitor
    btop
  ];

  home.sessionVariables = {
    NIX_PATH = "nixpkgs=${inputs.nixpkgs}";
  };
}
