{ pkgs, ... }:

let
  add-vfio = pkgs.callPackage ./add-vfio { };
in
{
  imports = [
    ./tap.nix
  ];

  environment.systemPackages = with pkgs; [
    add-vfio

    # RDP client to connect Windows VM, faster than spice.
    freerdp
  ];
}
