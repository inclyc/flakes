{ pkgs, lib, config, ... }:
{
  imports = [
    ../common
  ];

  home.homeDirectory = "/data/${config.home.username}";
  home.username = "lyc";

  home.packages = with pkgs; [
    rnix-lsp
    ccache
    ninja
  ] ++ (with pkgs.llvmPackages_15; [
    clang
    llvm
    lld
  ]);

  programs.git.signing.signByDefault = lib.mkForce false;
  programs.zsh.dirHashes = lib.mkForce {
    flakes = "/dev/shm/lyc/flakes";
    llvm = "/dev/shm/lyc/llvm-project";
  };
}
