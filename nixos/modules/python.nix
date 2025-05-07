/**
  Python development environment.
*/
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.inclyc.development.python;
in
{
  options = {
    inclyc.development.python.enable = lib.mkEnableOption "python development";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      (python3.withPackages (
        ps: with ps; [
          numpy
          requests
          matplotlib
          scipy
          ipykernel
          notebook
          jupyter
          scikit-learn
          torch
        ]
      ))
      poetry
    ];
  };
}
