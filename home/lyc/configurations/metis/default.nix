{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
{
  programs.git.signing.signByDefault = lib.mkForce false;
  programs.zsh.dirHashes = {
    flakes = "${config.home.homeDirectory}/flakes";
    llvm = "${config.home.homeDirectory}/llvm-project";
  };

  nix.registry.home = {
    from = {
      type = "indirect";
      id = "home";
    };
    flake = inputs.nixpkgs;
  };

  services.gpg-agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-curses;
  };

  inclyc.ssh.ICTProxy = true;
}
