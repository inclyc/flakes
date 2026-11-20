{
  buildPythonApplication,
  fetchPypi,
  setuptools,
}:
buildPythonApplication rec {
  pname = "ddns";
  version = "2.12.0";
  name = "${pname}-${version}";
  src = fetchPypi {
    inherit pname version;
    sha256 = "A41erAo7KOkgPpE+Izuof+MuUzOORPPraxFoj4/dtk0=";
  };

  pyproject = true;
  build-system = [ setuptools ];

  # Upstream setup.py requires a CI tag to determine the package version.
  env.TRAVIS_TAG = version;
}
