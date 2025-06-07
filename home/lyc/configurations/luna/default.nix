{
  config,
  lib,
  ...
}:
{
  programs.zsh.dirHashes = {
    flakes = "${config.home.homeDirectory}/flakes";
  };

  programs.git.signing.signByDefault = lib.mkForce false;
}
