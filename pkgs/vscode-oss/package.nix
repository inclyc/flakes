{ lib
, stdenv
, fetchFromGitHub
, buildGoModule
, cacert
, esbuild
, jq
, krb5
, libsecret
, makeWrapper
, moreutils
, nodejs_18
, electron_28
, nodePackages
, pkg-config
, python3
, ripgrep
, xorg
, yarn
, product ? (import ./product.nix { inherit lib; })
}:

let
  inherit (nodePackages) node-gyp;
  pname = "vscode";
  version = "1.89.1";
  commit = "dc96b837cf6bb4af9cd736aa3af08cf8279f7685";

  product' = product // {
    inherit version;
  };

  nodejs = nodejs_18;

  electron = electron_28;

  yarn' = yarn.override { inherit nodejs; };

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "vscode";
    rev = version;
    sha256 = "sha256-z4VA1pv+RPAzUOH/yK6EB84h4DOFG5TcRH443N7EIL0=";
  };

  vscodePlatforms =
    let
      msName = { os, arch }:
        let
          select = attrs: name: attrs.${name} or name;
          msOS = { darwin = "macOS"; };
          msArch = { x86_64 = "x64"; aarch64 = "arm64"; };
        in
        "${select msOS os}-${select msArch arch}";
      nixSystem = { os, arch }: "${arch}-${os}";
      supported = [
        { os = "linux"; arch = "x86_64"; }
        { os = "linux"; arch = "aarch64"; }
      ];
    in
    system: {
      # The name suitable for vscode gulp
      name =
        let
          supportedName = lib.mergeAttrsList
            (builtins.map (arg: { ${nixSystem arg} = msName arg; }) supported);
        in
          supportedName.${system} or (throw "Unsupported platform: ${system}");
    };
  system = stdenv.hostPlatform.system;

  platform = vscodePlatforms system;

  yarnCache = stdenv.mkDerivation {
    name = "${pname}-${version}-yarn-cache";
    inherit src;
    GIT_SSL_CAINFO = "${cacert}/etc/ssl/certs/ca-bundle.crt";
    NODE_EXTRA_CA_CERTS = "${cacert}/etc/ssl/certs/ca-bundle.crt";
    nativeBuildInputs = [
      yarn
    ];
    buildPhase = ''
      export HOME=$PWD
      yarn config set yarn-offline-mirror $out
      find "$PWD" -name "yarn.lock" -printf "%h\n" | \
        xargs -I {}
          yarn --cwd {}                                                        \
          --frozen-lockfile                                                    \
          --ignore-scripts                                                     \
          --ignore-platform                                                    \
          --ignore-engines                                                     \
          --no-progress                                                        \
          --non-interactive
    '';

    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = "sha256-7Qy0xMLcvmZ43EcNbsy7lko0nsXlbVYSMiq6aa4LuoQ=";
  };

  esbuild' = esbuild.override {
    buildGoModule = args: buildGoModule (args // rec {
      version = "0.17.14";
      src = fetchFromGitHub {
        owner = "evanw";
        repo = "esbuild";
        rev = "v${version}";
        hash = "sha256-4TC1d5FOZHUMuEMTcTOBLZZM+sFUswhyblI5HVWyvPA=";
      };
      vendorHash = "sha256-+BfxCyg0KkDQpHt/wycy/8CTG6YBA/VJvJFhhzUnSiQ=";
    });
  };

  # replaces esbuild's download script with a binary from nixpkgs
  patchEsbuild = path: version: ''
    mkdir -p ${path}/node_modules/esbuild/bin
    jq "del(.scripts.postinstall)" ${path}/node_modules/esbuild/package.json | sponge ${path}/node_modules/esbuild/package.json
    sed -i 's/${version}/${esbuild'.version}/g' ${path}/node_modules/esbuild/lib/main.js
    ln -s -f ${esbuild'}/bin/esbuild ${path}/node_modules/esbuild/bin/esbuild
  '';


in

stdenv.mkDerivation {
  inherit pname version src;

  outputs = [
    "out"

    # Remote extension host, for vscode-remote
    "reh"

    # Web extension host, run vscode in your browser
    "rehweb"
  ];

  nativeBuildInputs = [
    yarn'
    python3
    nodejs
    jq
    moreutils
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    krb5
    libsecret
    xorg.libX11
    xorg.libxkbfile
  ];

  patches = map (name: ./patches/${name})
    (builtins.attrNames (builtins.readDir ./patches));

  env = {
    # Disable NAPI_EXPERIMENTAL to allow to build with Node.js≥18.20.0.
    NIX_CFLAGS_COMPILE = "-DNODE_API_EXPERIMENTAL_NOGC_ENV_OPT_OUT";

    # Commit version embeded in vscode
    BUILD_SOURCEVERSION = commit;
  };

  postPatch = ''
    export HOME=$PWD
  '';

  configurePhase = ''
    runHook preConfigure

    # Generate product.json
    cp ${builtins.toFile "product.json" (builtins.toJSON product')} product.json

    # set offline mirror to yarn cache we created in previous steps
    yarn --offline config set yarn-offline-mirror "${yarnCache}"
    # set nodedir to prevent node-gyp from downloading headers
    # taken from https://nixos.org/manual/nixpkgs/stable/#javascript-tool-specific
    mkdir -p $HOME/.node-gyp/${nodejs.version}
    echo 9 > $HOME/.node-gyp/${nodejs.version}/installVersion
    ln -sfv ${nodejs}/include $HOME/.node-gyp/${nodejs.version}
    export npm_config_nodedir=${nodejs}
    # use updated node-gyp. fixes the following error on Darwin:
    # PermissionError: [Errno 1] Operation not permitted: '/usr/sbin/pkgutil'
    export npm_config_node_gyp=${node-gyp}/lib/node_modules/node-gyp/bin/node-gyp.js
    runHook postConfigure
  '';

  preBuild = ''
    export ELECTRON_SKIP_BINARY_DOWNLOAD=1
    export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
    export SKIP_SUBMODULE_DEPS=1
    export NODE_OPTIONS=--openssl-legacy-provider
  '';

  buildPhase = ''
    runHook preBuild

    # install dependencies
    yarn --offline                                                             \
         --ignore-scripts                                                      \
         --no-progress                                                         \
         --non-interactive

    # run yarn install everywhere, skipping postinstall so we can patch esbuild
    find . -path "*node_modules" -prune -o \
      -path "./*/*" -name "yarn.lock" -printf "%h\n" |                         \
        xargs -I {}                                                            \
          yarn --cwd {}                                                        \
               --frozen-lockfile                                               \
               --offline                                                       \
               --ignore-scripts                                                \
               --ignore-engines

    ${patchEsbuild "./build" "0.12.6"}
    ${patchEsbuild "./extensions" "0.11.23"}
    # patch shebangs of node_modules to allow binary packages to build
    patchShebangs .
    # put ripgrep binary into bin so postinstall does not try to download it
    find -path "*@vscode/ripgrep" -type d                                      \
      -execdir mkdir -p {}/bin \;                                              \
      -execdir ln -s ${ripgrep}/bin/rg {}/bin/rg \;
  '' + lib.optionalString stdenv.isDarwin ''
    # use prebuilt binary for @parcel/watcher, which requires macOS SDK 10.13+
    # (see issue #101229)
    pushd ./remote/node_modules/@parcel/watcher
    mkdir -p ./build/Release
    mv ./prebuilds/darwin-x64/node.napi.glibc.node ./build/Release/watcher.node
    jq "del(.scripts) | .gypfile = false" ./package.json | sponge ./package.json
    popd
  '' + ''
    npm rebuild --build-from-source
    npm rebuild --prefix remote/ --build-from-source
    # run postinstall scripts after patching
    find . -path "*node_modules" -prune -o \
      -path "./*/*" -name "yarn.lock" -printf "%h\n" | \
        xargs -I {} sh -c 'jq -e ".scripts.postinstall" {}/package.json >/dev/null && yarn --cwd {} postinstall --frozen-lockfile --offline || true'
    yarn --offline gulp core-ci
    yarn --offline gulp compile-extensions-build
    yarn --offline gulp compile-extension-media-build
    yarn --offline gulp vscode-reh-${platform.name}-min-ci
    yarn --offline gulp vscode-reh-web-${platform.name}-min-ci
    yarn --offline gulp vscode-${platform.name}-min-ci
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib $out/bin
    mv ../VSCode-${platform.name} $out/lib/vscode
    mv -T ../vscode-reh-${platform.name} $reh
    mv -T ../vscode-reh-web-${platform.name} $rehweb

    ln -s ${nodejs}/bin/node $reh/
    ln -s ${nodejs}/bin/node $rehweb/

    # Make a wrapper script, setting the electron path, and vscode path
    makeWrapper "$out/lib/vscode/bin/code-oss" "$out/bin/code-oss"             \
      --set ELECTRON '${lib.getExe electron}'                                  \
      --set VSCODE_PATH "$out/lib/vscode"

    runHook postInstall
  '';
}
