{ pkgs, lib, config, ... }:
{
  programs.vscode = {
    enable = true;
    userSettings = builtins.fromJSON (builtins.readFile ./settings.json);
    extensions = with pkgs.vscode-extensions; [
      vadimcn.vscode-lldb
      llvm-vs-code-extensions.vscode-clangd
      jnoortheen.nix-ide
      eamodio.gitlens
      mhutchie.git-graph
      asvetliakov.vscode-neovim
      arcticicestudio.nord-visual-studio-code
      usernamehw.errorlens
      james-yu.latex-workshop
      shardulm94.trailing-spaces
    ];
  };
}
