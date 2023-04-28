{ pkgs
, lib
, inputs
, system
, ...
}:
{
  programs.vscode = {
    enable = lib.mkDefault false;
    userSettings = (builtins.fromJSON (builtins.readFile ./settings.json));
    extensions = with inputs.nix-vscode-extensions.extensions.${system}.vscode-marketplace; [
      llvm-vs-code-extensions.vscode-clangd
      jnoortheen.nix-ide
      eamodio.gitlens
      mhutchie.git-graph
      asvetliakov.vscode-neovim
      arcticicestudio.nord-visual-studio-code
      usernamehw.errorlens
      james-yu.latex-workshop
      shardulm94.trailing-spaces
      colejcummins.llvm-syntax-highlighting
      ms-vscode-remote.remote-ssh
      mkhl.direnv
      ms-python.python
      ms-python.vscode-pylance
      lextudio.restructuredtext
    ];
  };
}
