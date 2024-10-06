{
  cacert,
  darwin,
  electron,
  fetchFromGitHub,
  fetchpatch,
  jq,
  krb5,
  lib,
  libsecret,
  makeDesktopItem,
  makeWrapper,
  moreutils,
  nodejs,
  nodePackages,
  pkg-config,
  prefetch-npm-deps,
  python3,
  ripgrep,
  stdenv,
  stdenvNoCC,
  xorg,

  # Customize product.json, with some reasonable defaults
  product ? (import ./product.nix { inherit lib; }),

  shortName ? "Code - OSS",
  longName ? "Code - OSS",
  executableName ? "code-oss",

  # Extension gallery to use in vscode. It is open-vsix registry by default.
  extensionsGallery ? {
    serviceUrl = "https://open-vsx.org/vscode/gallery";
    itemUrl = "https://open-vsx.org/vscode/item";
  },

  # Override product.json
  productOverrides ? { },

  # Mangling.
  # Disable mangling can significantly speed up the compilation process
  # But increases closure size by approximately 200KB.
  mangle ? false,
}:

let
  inherit (nodePackages) node-gyp;
  inherit (darwin) autoSignDarwinBinariesHook;

  common = import ./common.nix {
    inherit
      lib
      makeDesktopItem
      shortName
      longName
      executableName
      ;
  };

  inherit (common) desktopItem urlHandlerDesktopItem;

  # Give all platform related information in this lambda.
  vscodePlatforms =
    hostPlatform:
    let
      select = attrs: name: attrs.${name} or name;
    in
    {
      ms = rec {
        # Map Microsoft system names.
        os = select {
          Darwin = "darwin";
          Linux = "linux";
        } hostPlatform.uname.system;
        arch = select {
          x86_64 = "x64";
          aarch64 = "arm64";
        } hostPlatform.uname.processor;
        # The name, interpolate it in gulp build tasks
        name = "${os}-${arch}";
      };
    };

  platform = vscodePlatforms stdenv.hostPlatform;
in

stdenv.mkDerivation (finalAttrs: {
  pname = executableName;
  version = "1.94.0";
  commit = "38c31bc77e0dd6ae88a4e9cc93428cc27a56ba40";

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "vscode";
    rev = finalAttrs.version;
    sha256 = "sha256-klGQ7fqZhyOqTIGtwDn8Zvi7lgbwdzW+FTujBQ2uFTU=";
  };

  passthru.product =
    # Base
    product
    // {
      inherit (finalAttrs) version;
      inherit extensionsGallery;

      nameShort = shortName;
      nameLong = longName;
      applicationName = executableName;
    }
    # Extra overrides
    // productOverrides;

  npmCache = stdenvNoCC.mkDerivation (
    let
      inherit (finalAttrs) pname version src;
    in
    {
      inherit src;
      name = "${pname}-${version}-npm-cache";
      GIT_SSL_CAINFO = "${cacert}/etc/ssl/certs/ca-bundle.crt";
      NODE_EXTRA_CA_CERTS = "${cacert}/etc/ssl/certs/ca-bundle.crt";
      nativeBuildInputs = [ nodePackages.npm ];
      buildPhase = ''
        export HOME="$PWD"
        mkdir -p "$out"
        npm config set cache "$out"
        find "$PWD" -name "package-lock.json" -printf "%h\n" |                 \
          xargs -I {}                                                          \
            npm --prefix {} ci                                                 \
              --ignore-scripts                                                 \
              --no-audit                                                       \
              --no-fund                                                        \
              --no-progress                                                    \
              --loglevel=error

        # Clean logs file to make sure this is reproducible
        rm -rf "$out/_logs"
        mkdir -p "$out/_logs"
      '';

      dontFixup = true;

      outputHashMode = "recursive";
      outputHashAlgo = "sha256";
      outputHash = "sha256-JicYO5GQHPfyTM1LGFA4dzb1t/D3/n9w0jwKpPukFTM=";
    }
  );

  outputs = [
    # Desktop version.
    "out"

    # Remote extension host, for vscode remote development
    "reh"

    # Web extension host, run extension host in CLI, client in browser
    "rehweb"
  ];

  nativeBuildInputs =
    [
      python3
      nodejs
      jq
      moreutils
      pkg-config
      makeWrapper
      nodePackages.node-gyp-build
    ]
    ++ lib.optionals stdenv.isDarwin [ darwin.cctools ]
    ++ lib.optionals (stdenv.isDarwin && stdenv.isAarch64) [ autoSignDarwinBinariesHook ];

  buildInputs = [
    krb5
    libsecret
    xorg.libX11
    xorg.libxkbfile
  ] ++ lib.optionals stdenv.isDarwin [ darwin.apple_sdk.frameworks.Cocoa ];

  patches = [
    # build/npm/postinstall: remove git config
    (fetchpatch {
      name = "remove-git-config.patch";
      url = "https://github.com/microsoft/vscode/commit/56a24c8260241f84c21223e5693eecc5f1be3107.patch";
      sha256 = "sha256-mP7nWXkQpNndcVFvSEv650OrKBYIsX7bl2SIVY+gTzU=";
    })
    # build: omit nodejs download
    (fetchpatch {
      name = "omit-nodejs-download.patch";
      url = "https://github.com/microsoft/vscode/commit/a3e32c2f004e7700753d20f01cf526fab569b3c9.patch";
      sha256 = "sha256-SuzBCsfoGgLRlbPW3NnsV1UTzAQn50TXPltl4ZpMSHU=";
    })
    # build: omit electron download
    (fetchpatch {
      name = "omit-electron-download.patch";
      url = "https://github.com/microsoft/vscode/commit/0c747805ca1c0e0f4db728543bb35248999d5ed8.patch";
      sha256 = "sha256-XOwiWHnR3ICIdSU/Utfj5c/UjL7FxHg1QBl1DtdKTMg=";
    })
    # resources/linux: remove VSCODE_PATH and ELECTRON path setting
    (fetchpatch {
      name = "remove-vscodes-path-and-electron-path-setting.patch";
      url = "https://github.com/microsoft/vscode/commit/cacc3e56dede46d0e5db7a08db61c7024ad16855.patch";
      sha256 = "sha256-EwWBC+0i28ChwbJJeNJShk8I4L54+l5jtSdiVrGxBxQ=";
    })
    # resources/darwin: remove darwin-bundled electron
    (fetchpatch {
      name = "remove-darwin-bundled-electron.patch";
      url = "https://github.com/microsoft/vscode/commit/8e6e9671ebdee5d83353c7fd2997e3a64d0d4b6e.patch";
      sha256 = "sha256-xdC/lVNO0O2cMxmm40DMIHpjQn3uuFrrkBYvCib09/U=";
    })
    # build/npm: remove patching directory
    (fetchpatch {
      name = "remove-patching-directory.patch";
      url = "https://github.com/microsoft/vscode/commit/cd6b8ad5c20d5bfca8b136b3ecd98dde6a56ceec.patch";
      sha256 = "sha256-JVcB/+IFCAq2OGcgPmt84fuGinXyDsPfjJAuZ24SvOc=";
    })
    # build/npm/postinstall: patch out npm_command
    (fetchpatch {
      name = "postinstall-patch-npm-command.patch";
      url = "https://github.com/microsoft/vscode/commit/3b576aa402e9ae75c9acd340fe1d29dbcd59e21e.patch";
      sha256 = "sha256-unaH4cCuRiQoe62fmULiLaEardwzmczoFZY/Ky5kchY=";
    })
  ];

  env = {
    # Disable NAPI_EXPERIMENTAL to allow to build with Node.js≥18.20.0.
    NIX_CFLAGS_COMPILE = "-DNODE_API_EXPERIMENTAL_NOGC_ENV_OPT_OUT";

    # Commit version embeded in vscode
    BUILD_SOURCEVERSION = finalAttrs.commit;

    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
    PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
    SKIP_SUBMODULE_DEPS = "1";
    NODE_OPTIONS = "--openssl-legacy-provider";

    # nodejs v20 have this known issue:
    # https://github.com/nodejs/node/issues/51555
    DISABLE_V8_COMPILE_CACHE = "1";

    npm_config_node_gyp = "${node-gyp}/bin/node-gyp.js";
    npm_config_nodedir = nodejs;
    npm_config_offline = "true";
  };

  configurePhase = ''
    runHook preConfigure

    export HOME=$PWD

    echo "Copying npm cache"
    # Make the cache writable by coping it here
    mkdir -p "$HOME/.npm-cache"
    cp -a "${finalAttrs.npmCache}/." "$HOME/.npm"
    # Ensure that the cache is writable
    chmod -R u+w "$HOME/.npm"
    export npm_config_cache="$HOME/.npm"

    # Generate product.json
    cp ${builtins.toFile "product.json" (builtins.toJSON finalAttrs.passthru.product)} product.json

    # set offline mirror to yarn cache we created in previous steps
    # set nodedir to prevent node-gyp from downloading headers
    # taken from https://nixos.org/manual/nixpkgs/stable/#javascript-tool-specific
    mkdir -p $HOME/.node-gyp/${nodejs.version}
    echo 9 > $HOME/.node-gyp/${nodejs.version}/installVersion
    ln -sfv ${nodejs}/include $HOME/.node-gyp/${nodejs.version}
    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild
    for dir in . remote build extensions; do
      pushd "$dir"
      npm ci --ignore-scripts
      popd
    done

    patchShebangs .

    # put ripgrep binary into bin so postinstall does not try to download it
    find -path "*@vscode/ripgrep" -type d                                    \
      -execdir mkdir -p {}/bin \;                                            \
      -execdir ln -s ${ripgrep}/bin/rg {}/bin/rg \;

    patch -u node_modules/kerberos/binding.gyp -i ${./patches/npm/binding.gyp.patch}
    npm rebuild --build-from-source --ignore-scripts


    npm rebuild --build-from-source --prefix build
    npm rebuild --build-from-source --prefix extensions
    patch -u remote/node_modules/kerberos/binding.gyp -i ${./patches/npm/binding.gyp.patch}
    npm rebuild --build-from-source --prefix remote

    patchShebangs .

    npm run postinstall

    npm run gulp core-ci${lib.optionalString (!mangle) "-pr"}
    npm run gulp compile-extensions-build
    npm run gulp compile-extension-media-build
    npm run gulp vscode-reh-${platform.ms.name}-min-ci
    npm run gulp vscode-reh-web-${platform.ms.name}-min-ci
    npm run gulp vscode-${platform.ms.name}-min-ci
    runHook postBuild
  '';

  installPhase =
    let
      binName = if stdenv.isDarwin then "resources/app/bin/code" else "bin/code-oss";
    in
    ''
      runHook preInstall
      mkdir -p $out/lib $out/bin
      mv ../VSCode-${platform.ms.name} $out/lib/vscode
      mv -T ../vscode-reh-${platform.ms.name} $reh
      mv -T ../vscode-reh-web-${platform.ms.name} $rehweb

      ln -s ${nodejs}/bin/node $reh/
      ln -s ${nodejs}/bin/node $rehweb/
    ''
    + lib.optionalString stdenv.isLinux ''
      mkdir -p $out/share/applications
      ln -s ${desktopItem}/share/applications/${executableName}.desktop $out/share/applications/${executableName}.desktop
      ln -s ${urlHandlerDesktopItem}/share/applications/${executableName}-url-handler.desktop $out/share/applications/${executableName}-url-handler.desktop
      install -D $out/lib/vscode/resources/app/resources/linux/code.png $out/share/icons/${executableName}.png
    ''
    + ''
      # Make a wrapper script, setting the electron path, and vscode path
      makeWrapper "$out/lib/vscode/${binName}" "$out/bin/code-oss"             \
        --set ELECTRON '${lib.getExe electron}'                                \
        --set VSCODE_PATH "$out/lib/vscode"
      runHook postInstall
    '';

  meta = common.meta // {
    homepage = "https://github.com/microsoft/vscode";
    maintainers = with lib.maintainers; [ inclyc ];
  };
})
