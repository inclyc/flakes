{ pkgs, ... }:

let
  add-vfio = pkgs.callPackage ./add-vfio { };
in
{
  environment.systemPackages = [
    add-vfio
  ];
}
