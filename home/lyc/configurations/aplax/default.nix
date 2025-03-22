{
  inputs,
  pkgs,
  config,
  ...
}:
{
  programs.vscode = {
    enable = true;
    profiles.default.userSettings = {
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

    # Rust
    cargo
    rustc

    (androidenv.composeAndroidPackages {
      platformToolsVersion = "35.0.2";
    }).platform-tools

    # Python
    uv
    (python3.withPackages (
      ps: with ps; [
        black
        ipykernel
      ]
    ))

    mtr
  ];

  home.sessionVariables = {
    NIX_PATH = "nixpkgs=${inputs.nixpkgs}";
    ANDROID_SDK_ROOT = "${config.home.homeDirectory}/.nix-profile/libexec/android-sdk";
  };
}
