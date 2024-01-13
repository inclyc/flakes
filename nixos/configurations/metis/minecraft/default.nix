{ pkgs, ... }:
{
  imports = [
    ./msd.nix
    ./dawncraft.nix
  ];

  lib.pkgs = {
    authlib-injector = pkgs.fetchurl {
      url = "https://github.com/yushijinhun/authlib-injector/releases/download/v1.2.4/authlib-injector-1.2.4.jar";
      hash = "sha256-eVsnbLQIVe0E3H/KvCptFQ3kYAtUKHWmUi5l9rJbyp8=";
    };
  };
}
