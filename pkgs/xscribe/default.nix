{
  lib,
  python3,
}:

python3.pkgs.buildPythonApplication {
  pname = "xscribe";
  version = "0.1.0";
  pyproject = true;

  src = lib.cleanSource ./.;

  build-system = [
    python3.pkgs.hatchling
  ];

  dependencies = with python3.pkgs; [
    pyyaml
  ];

  pythonImportsCheck = [
    "xscribe"
  ];

  meta = with lib; {
    description = "A periodic Python service initialized with uv";
    license = licenses.mit;
    maintainers = [ ];
  };
}
