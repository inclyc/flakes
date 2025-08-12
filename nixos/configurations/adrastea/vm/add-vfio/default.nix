{
  lib,
  rustPlatform,
}:

rustPlatform.buildRustPackage {
  name = "add-vfio";

  src = ./.;

  cargoHash = "sha256-nMu3x9SGgKsxNEwFS5JQ9VOhLnEAYBMDNRG18Ciz0kI=";

  meta = {
    license = lib.licenses.unlicense;
    maintainers = [ lib.maintainers.inclyc ];
  };
}
