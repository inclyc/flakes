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
  programs.zsh.dirHashes = {
    flakes = "${config.home.homeDirectory}/flakes";
    llvm = "${config.home.homeDirectory}/llvm-project";
  };
}
