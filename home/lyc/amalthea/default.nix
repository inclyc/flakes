{ pkgs, lib, config, ... }:
{
  imports = (import ../common);

  home.packages = with pkgs; [
    tree
    nix-index
    nix-output-monitor
    nix-tree
    python3
    htop
    (pkgs.texlive.combine {
      inherit (pkgs.texlive) scheme-full;
    })
    pinentry
  ];
  home.homeDirectory = "/Users/${config.home.username}";
  home.username = "inclyc";

  programs.vscode.extensions = (with pkgs.vscode-extensions; [
    # vadimcn.vscode-lldb
    # Code LLDB is currently not working
    # https://github.com/NixOS/nixpkgs/issues/202507
    llvm-vs-code-extensions.vscode-clangd
    jnoortheen.nix-ide
    eamodio.gitlens
    mhutchie.git-graph
    asvetliakov.vscode-neovim
    arcticicestudio.nord-visual-studio-code
    usernamehw.errorlens
    james-yu.latex-workshop
    shardulm94.trailing-spaces
    ms-vscode-remote.remote-ssh
  ]);

  programs.vscode.userSettings = (builtins.fromJSON (builtins.readFile ./vscode-settings.json));
}
