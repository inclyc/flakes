{ pkgs, lib, config, ... }:
{
  programs.vscode = {
    enable = lib.mkDefault true;
    userSettings = (builtins.fromJSON (builtins.readFile ./settings.json));
    extensions = lib.mkDefault (with pkgs.vscode-extensions; [
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
    ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "llvm-syntax-highlighting";
        publisher = "colejcummins";
        version = "0.0.3";
        sha256 = "sha256-D5zLp3ruq0F9UFT9emgOBDLr1tya2Vw52VvCc40TtV0=";
      }
    ]);
  };
}
