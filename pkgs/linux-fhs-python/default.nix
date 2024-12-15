{
  buildFHSEnv,
  lib,
  python3,
}:

let
  name = "linux-fhs-python";
in
buildFHSEnv {
  inherit name;
  targetPkgs =
    pkgs:
    (with pkgs; [
      stdenv.cc
      perl
      python3
      libGL
      glib
      zlib
      git
      openssh
      cudatoolkit
    ]);
  runScript = lib.getExe python3;
  meta.mainProgram = name;
}
