{
  stdenv,
  fetchurl,
  autoPatchelfHook,
  gnutar,
}:

let
  inherit (stdenv.hostPlatform) system;
  sources = builtins.fromJSON (builtins.readFile ./sources.json);
in
stdenv.mkDerivation {
  pname = "vscodium-reh";
  version = "1.95.3.24321";

  sourceRoot = ".";

  src = fetchurl sources."vscodium-reh".${system};

  unpackPhase = ''
    mkdir -p "$out"
    tar -C "$out" -xvzf "$src"
  '';

  buildInputs = [
    stdenv.cc.cc.lib
  ];

  nativeBuildInputs = [
    autoPatchelfHook
    gnutar
  ];

  passthru.updateScript = ./update-codium-reh.py;
}
