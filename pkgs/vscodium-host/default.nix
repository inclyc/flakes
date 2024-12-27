{
  stdenv,
  fetchurl,
  autoPatchelfHook,
  gnutar,

  pname,
  assetName,
}:

let
  inherit (stdenv.hostPlatform) system;
  sources = builtins.fromJSON (builtins.readFile ./sources.json);
in
stdenv.mkDerivation {
  inherit pname;
  version = "1.96.2.24355";

  sourceRoot = ".";

  src = fetchurl sources.${assetName}.${system};

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

  passthru.updateScript = ./update.py;
}
