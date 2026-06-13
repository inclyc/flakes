{
  lib,
  stdenv,
  fetchurl,
}:

let
  version = "15.12.3";
  srcs = {
    x86_64-linux = fetchurl {
      url = "https://github.com/can1357/oh-my-pi/releases/download/v${version}/omp-linux-x64";
      sha256 = "1p8psc10cd1dn8wnl1mizq2rr7mfk3g4i5746s8xh1p4nwgvp52h";
    };
    aarch64-linux = fetchurl {
      url = "https://github.com/can1357/oh-my-pi/releases/download/v${version}/omp-linux-arm64";
      hash = "sha256-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX="; # TODO: prefetch
    };
    x86_64-darwin = fetchurl {
      url = "https://github.com/can1357/oh-my-pi/releases/download/v${version}/omp-darwin-x64";
      hash = "sha256-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX="; # TODO: prefetch
    };
    aarch64-darwin = fetchurl {
      url = "https://github.com/can1357/oh-my-pi/releases/download/v${version}/omp-darwin-arm64";
      hash = "sha256-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX="; # TODO: prefetch
    };
  };
in
stdenv.mkDerivation {
  pname = "omp";
  inherit version;

  src = srcs.${stdenv.hostPlatform.system} or (throw "unsupported system: ${stdenv.hostPlatform.system}");

  # IMPORTANT: Do NOT use autoPatchelfHook.
  # Bun SEA (Single Executable Application) binaries embed application code
  # in ELF sections that get corrupted when autoPatchelf modifies the binary.
  # The raw binary works on NixOS as-is since Bun bundles its own runtime.

  dontUnpack = true;
  dontBuild = true;
  dontPatch = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp $src $out/bin/omp
    chmod +x $out/bin/omp

    runHook postInstall
  '';

  meta = with lib; {
    description = "AI Coding agent for the terminal — hash-anchored edits, LSP, DAP, subagents";
    homepage = "https://omp.sh";
    license = licenses.mit;
    platforms = builtins.attrNames srcs;
    mainProgram = "omp";
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
