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
