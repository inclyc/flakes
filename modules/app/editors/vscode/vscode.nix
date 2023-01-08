{ pkgs, lib, config, ... }:
{
  programs.vscode = {
    enable = true;
    userSettings = {
      "files.autoSave" = "onFocusChange";
      "editor.lineNumbers" = "relative";
      "files.trimFinalNewlines" = true;
      "files.trimTrailingWhitespace" = true;
      "nix.serverPath" = "rnix-lsp";
      "nix.enableLanguageServer" = true;
      "workbench.colorTheme" = "Nord";
      "editor.formatOnSave" = true;
      "editor.formatOnSaveMode" = "modifications";

      "[nix]" = {
        "editor.tabSize" = 2;
      };
    };
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
