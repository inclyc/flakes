{
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage {
  pname = "git-branch-clean";
  version = "0.1.0";

  src = ./.;

  cargoHash = "sha256-YVL/cqZ/zwadwHlNTs7GqfkMoLOQCn5P5m5vb0WvFVw=";

  useFetchCargoVendor = true;

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ];
}
