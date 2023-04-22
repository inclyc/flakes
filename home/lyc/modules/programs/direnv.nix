{ lib
, ...
}:
{
  programs.direnv = {
    enable = lib.mkDefault true;
    enableZshIntegration = lib.mkDefault true;
    nix-direnv.enable = lib.mkDefault true;
  };
}
