{
  stdenv,
  fetchurl,
  autoPatchelfHook,
  gnutar,
  zlib,
}:

let
  inherit (stdenv.hostPlatform) system;
  sources = builtins.fromJSON (builtins.readFile ./sources.json);
in
stdenv.mkDerivation {
  pname = "vscode-web-host";
  version = "1.96.2";

  sourceRoot = ".";

  src = fetchurl sources."vscode-server".${system};

  unpackPhase = ''
    mkdir -p "$out"
    tar --strip-components=1 -C "$out" -xvzf "$src"
  '';

  buildInputs = [
    stdenv.cc.cc.lib
    zlib
  ];

  nativeBuildInputs = [
    autoPatchelfHook
    gnutar
  ];
}
