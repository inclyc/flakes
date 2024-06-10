{ lib, ... }:
{
  imports = [
    ./programs/direnv.nix
    ./programs/git.nix
    ./programs/gpg.nix
    ./programs/ssh.nix
    ./programs/vscode/vscode.nix
    ./programs/zsh/zsh.nix
    ./user.nix
  ];

  home.stateVersion = lib.mkDefault "22.11";
}
