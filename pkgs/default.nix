{
  pkgs ? (import ../nixpkgs.nix) { },
}:
{
  topsap = pkgs.callPackage ./topsap { };
  ddns = pkgs.python3.pkgs.callPackage ./ddns { };

  simsun = pkgs.callPackage ./simsun { };

  waydroid-script = pkgs.python3Packages.callPackage ./waydroid-script { };

  git-branch-clean = pkgs.callPackage ./git-branch-clean { };

  segoe-ui-variable = pkgs.callPackage ./segoe-ui-variable { };

  segoe-ui = pkgs.callPackage ./segoe-ui { };
}
