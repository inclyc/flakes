{ pkgs, ... }:

let
  androidenv = pkgs.androidenv.composeAndroidPackages {
    platformToolsVersion = "35.0.2";
    includeNDK = true;
    ndkVersions = [ "27.3.13750724" ];
  };
in
{
  home.packages = [
    androidenv.platform-tools
    androidenv.ndk-bundle
  ];
}
