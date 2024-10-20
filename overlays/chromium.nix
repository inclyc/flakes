final: prev:
let
  inherit (prev) system lib hostPlatform;
  inherit (hostPlatform) isLinux;

  args = lib.optionals isLinux [
    # If the host platform is linux, we'd like to prefer ozone-platform=wayland.
    "--ozone-platform=wayland"
    "--enable-features=WaylandWindowDecorations"
    # Enable wayland ime to support input methods.
    "--enable-wayland-ime"
    "--disable-features=WaylandFractionalScaleV1"
  ];

in
lib.foldl'
  (
    acc: pkgName:
    acc
    // {
      ${pkgName} = prev.${pkgName}.override {
        commandLineArgs = lib.escapeShellArgs args;
      };
    }
  )
  { }
  [
    "chromium"
    "vscodium"
  ]
