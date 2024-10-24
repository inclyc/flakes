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
      "remote.OSS.hosts" = [
        {
          type = "manual";
          name = "metis-interpreter";
          host = "localhost";
          port = 47560;
          connectionToken = false;
          folders = [
            {
              name = "ast-interpreter";
              path = "/root/ast-interpreter";
            }
          ];
        }
        {
          type = "manual";
          name = "adrastea-zxy";
          host = "localhost";
          port = 47561;
          connectionToken = false;
          folders = [ ];
        }
      ];
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

    ollama

    nodejs
    yarn

    meson
    ninja

    nixd

    xquartz

    poetry

    pandoc
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
