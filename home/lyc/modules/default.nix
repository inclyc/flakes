{ lib, pkgs, ... }:
{
  imports = [
    ./programs/direnv.nix
    ./programs/git.nix
    ./programs/gpg.nix
    ./programs/nvim/nvim.nix
    ./programs/ssh.nix
    ./programs/tmux.nix
    ./programs/vscode/vscode.nix
    ./programs/zsh/zsh.nix
    ./user.nix
  ];

  home.stateVersion = lib.mkDefault "22.11";

}
