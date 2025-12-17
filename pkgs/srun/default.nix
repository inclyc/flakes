{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage {
  name = "srun";

  src = fetchFromGitHub {
    owner = "zu1k";
    repo = "srun";
    tag = "0.6.2";
    sha256 = "sha256-x712acOwrMtrmSGjQeMco2avVotcJs32ZbYvcTjvBtk=";
  };

  cargoHash = "sha256-mKS0S0leKxz38Zxu9yxjA1WjwymUSPqJh4DIdFPRPp4=";

  env.AUTH_SERVER_IP = "10.0.0.1";

  meta = {
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.inclyc ];
  };
}
