{ pkgs, lib, config, ... }:
{
  home.packages = with pkgs; [
    rnix-lsp
    ninja
    ccache
  ] ++ (with pkgs.llvmPackages_15; [
    clang
    llvm
    lld
  ]);

  programs.git.signing.signByDefault = lib.mkForce false;
  programs.zsh.dirHashes = lib.mkForce {
    flakes = "/home/lyc/flakes";
    llvm = "/home/lyc/llvm-project";
  };
}
