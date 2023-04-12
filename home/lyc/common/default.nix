{ lib, pkgs, ... }:
{
  imports = [
    ../../common
    ./programs/git.nix
    ./programs/gpg.nix
    ./programs/nvim/nvim.nix
    ./programs/ssh.nix
    ./programs/tmux.nix
    ./programs/vscode/vscode.nix
    ./programs/zsh/zsh.nix
    ./user.nix
  ];

  home = {
    stateVersion = lib.mkDefault "22.11";
    packages = with pkgs; [
      tree
      nix-index
      nix-output-monitor
      nix-tree
      python3
      htop

      # C/C++ build system
      cmake
      meson
      bear
    ];
  };

}
