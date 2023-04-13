{ config, lib, ... }:
{
  programs.gpg.enable = lib.mkDefault true;
}
