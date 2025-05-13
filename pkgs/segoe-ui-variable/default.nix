{
  stdenvNoCC,
  lib,
  fetchzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "segoe-ui-variable";
  version = "0-unstable-2024-06-06";

  src = fetchzip {
    url = "https://aka.ms/SegoeUIVariable";
    extension = "zip";
    stripRoot = false;
    hash = "sha256-s82pbi3DQzcV9uP1bySzp9yKyPGkmJ9/m1Q6FRFfGxg=";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/{fonts/truetype,licenses/segoe-ui-variable}
    ln -s ${finalAttrs.src}/EULA.txt $out/share/licenses/segoe-ui-variable/LICENSE
    for font in *.ttf; do
      ln -s ${finalAttrs.src}/"$font" $out/share/fonts/truetype/"$font"
    done

    runHook postInstall
  '';

  meta = {
    description = "The new system font for Windows";
    homepage = "https://learn.microsoft.com/en-us/windows/apps/design/downloads/#fonts";
    license = lib.licenses.unfree; # Guessing, haven't read what EULA allows
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
})
