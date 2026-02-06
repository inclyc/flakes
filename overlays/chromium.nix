final: prev:
let
  inherit (prev) lib stdenv;
  inherit (stdenv) hostPlatform;
  inherit (hostPlatform) isLinux;

  args = lib.optionals isLinux [
    # If the host platform is linux, we'd like to prefer ozone-platform=wayland.
    "--ozone-platform=wayland"
    "--enable-features=WaylandWindowDecorations"
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
  ]
