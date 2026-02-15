{
  inputs,
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./android.nix
  ];

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
    cmake

    nixd

    pandoc

    elan

    rsync

    # Resources monitor
    btop

    # Rust
    cargo
    rustc
    rustPackages.clippy
    rustPackages.rustfmt

    # Python
    uv
    (python3.withPackages (
      ps: with ps; [
        black
        ipykernel
        pygit2
      ]
    ))

    mtr

    android-tools
    (scrcpy.overrideAttrs (oldAttrs: {
      # https://github.com/NixOS/nixpkgs/pull/239217#discussion_r1239319034
      postPatch = "";
    }))

    typst

    biome

    tailscale

    zju-connect
  ];

  programs.ssh.matchBlocks = {
    luna = {
      hostname = "luna.local";
      user = "lyc";
      port = 22;
    };
  };

  programs.ssh.enableDefaultConfig = false;

  home.sessionVariables = {
    NIX_PATH = "nixpkgs=${inputs.nixpkgs}";
    ANDROID_SDK_ROOT = "${config.home.homeDirectory}/.nix-profile/libexec/android-sdk";
    RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
  };
}
