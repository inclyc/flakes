{
  lib,
  stdenv,
  makeBinaryWrapper,
  agentEnv,
}:
pkg:
stdenv.mkDerivation {
  name = "${pkg.pname or (builtins.parseDrvName pkg.name).name}-sandboxed";
  nativeBuildInputs = [ makeBinaryWrapper ];
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out
    shopt -s nullglob
    for item in ${lib.getBin pkg}/*; do
      name=$(basename "$item")
      if [ "$name" != "bin" ]; then
        ln -s "$item" "$out/$name"
      fi
    done
    mkdir -p $out/bin
    for prog in ${lib.getBin pkg}/bin/*; do
      if [ ! -f "$prog" ] || [ ! -x "$prog" ]; then
        continue
      fi
      name=$(basename "$prog")
      makeWrapper ${agentEnv}/bin/agent-env "$out/bin/$name" \
        --add-flags "$prog"
    done
  '';
}
