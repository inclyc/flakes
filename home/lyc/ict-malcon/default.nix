{ pkgs, lib, config, ... }:
{
  imports =
    (import ../common/shells) ++
    (import ../common/applications) ++
    (import ../common/tools/misc) ++
    (import ../common/tools/networking) ++
    (import ../common/tools/package-management)
    ++ [ ../common/global.nix ];

  programs.vscode.enable = lib.mkForce false;

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
