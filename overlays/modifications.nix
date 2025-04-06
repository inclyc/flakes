final: prev:
let
  inherit (prev) lib;
in
(lib.composeManyExtensions [
  (import ./chromium.nix)
  (import ./vscode)
])
  final
  prev
