{ pkgs, lib, config, ... }:
{
  imports =
    (import ../common/shells) ++
    (import ../common/applications/version-management)
    ++ [ ../common/global.nix ];

  home.packages = with pkgs; [
    rnix-lsp
  ];

  programs.git.signing.signByDefault = lib.mkForce false;
}
