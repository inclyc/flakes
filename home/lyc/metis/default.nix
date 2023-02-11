{ pkgs, lib, config, ... }:
{
  imports =
    (import ../common/shells) ++
    (import ../common/applications)
    ++ [ ../common/global.nix ];

  home.packages = with pkgs; [
    rnix-lsp
  ];

  programs.git.signing.signByDefault = lib.mkForce false;
  programs.zsh.dirHashes = lib.mkForce {
    flakes = "$HOME/flakes";
    llvm = "$HOME/llvm-project";
  };
}
