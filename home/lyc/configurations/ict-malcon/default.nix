{
  pkgs,
  lib,
  config,
  ...
}:
{

  home.homeDirectory = "/data/${config.home.username}";
  home.username = "lyc";

  home.packages =
    with pkgs;
    [ ninja ]
    ++ (with pkgs.llvmPackages; [
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
