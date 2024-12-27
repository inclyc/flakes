{
  lib,
  rustPlatform,
}:

rustPlatform.buildRustPackage {
  name = "add-vfio";

  src = ./.;

  cargoHash = "sha256-uDN154Y3QFw6jksEA0Z+AFgB1n0s4EFznXIC7Q+xOtQ=";

  meta = {
    license = lib.licenses.unlicense;
    maintainers = [ lib.maintainers.inclyc ];
  };
}
