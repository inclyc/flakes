{ pkgs
, lib
, inputs
, system
, config
, ...
}:
{
  programs.vscode = {
    enable = lib.mkDefault false;
    userSettings = (builtins.fromJSON (builtins.readFile ./settings.json)) //
      (
        let
          nvimPath = "${pkgs.neovim}/bin/nvim";
          zshPath = "${pkgs.zsh}/bin/zsh";
        in
        {
          # path.linux may specified "incorrectly" on darwin
          # because it will link to *darwin* executable. This configuration
          # should be evaulated on corresponding platform, and chosed by vscode.
          "vscode-neovim.neovimExecutablePaths.linux" = nvimPath;
          "vscode-neovim.neovimExecutablePaths.darwin" = nvimPath;

          "terminal.integrated.profiles.osx".zsh.path = zshPath;
          "terminal.integrated.profiles.linux".zsh.path = zshPath;
          "nix.enableLanguageServer" = true;
          "nix.serverPath" = "${lib.getExe pkgs.nixd}";
        }
      );
    extensions = (with inputs.nix-vscode-extensions.extensions.${system}.vscode-marketplace; [
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
      mkhl.direnv
      ms-python.python
      ms-python.vscode-pylance
      lextudio.restructuredtext

      # Java
      redhat.java
      vscjava.vscode-java-debug
      vscjava.vscode-java-dependency
      vscjava.vscode-gradle
    ]) ++ (with pkgs.vscode-extensions; [
      ms-vscode-remote.remote-ssh
    ]);
  };

  home.packages = with pkgs; [
    nil
    nixpkgs-fmt
  ];
}
