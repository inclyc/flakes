{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.inclyc.development.android;
  androidenv = pkgs.androidenv.composeAndroidPackages {
    platformToolsVersion = "35.0.2";
    includeNDK = true;
    ndkVersions = [ "27.3.13750724" ];
  };
in
{
  options = {
    inclyc.development.android.enable = lib.mkEnableOption "Android development";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      androidenv.platform-tools
    ];

    home.sessionVariables = {
      "ANDROID_NDK" = androidenv.ndk-bundle;
    };
  };
}
