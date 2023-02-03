{ pkgs, lib, config, ... }:
{
  imports = (import ../common);

  home.packages = with pkgs; [
    pinentry_mac
  ];
  home.homeDirectory = "/Users/${config.home.username}";
  home.username = "inclyc";

  programs.vscode.extensions = (with pkgs.vscode-extensions; [
    llvm-vs-code-extensions.vscode-clangd
    jnoortheen.nix-ide
    eamodio.gitlens
    mhutchie.git-graph
    asvetliakov.vscode-neovim
    arcticicestudio.nord-visual-studio-code
    usernamehw.errorlens
    james-yu.latex-workshop
    shardulm94.trailing-spaces

  ]);

  programs.vscode.userSettings = (builtins.fromJSON (builtins.readFile ./vscode-settings.json));
}
