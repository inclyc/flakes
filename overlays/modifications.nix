final: prev:
let
  inherit (prev) lib;
in
(lib.composeManyExtensions [
  (import ./chromium.nix)
  (import ./openssh)
])
  final
  prev
