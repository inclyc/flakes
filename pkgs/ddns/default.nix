{ buildPythonApplication
, fetchPypi
}:
buildPythonApplication
rec {
  pname = "ddns";
  version = "2.12.0";
  name = "${pname}-${version}";
  src = fetchPypi {
    inherit pname version;
    sha256 = "A41erAo7KOkgPpE+Izuof+MuUzOORPPraxFoj4/dtk0=";
  };

  # Ungly hack for https://github.com/NewFuture/DDNS/blob/a1a8f8565c80d9702a49fcb45f18b32dfb4dba26/setup.py#L47
  # setup a fack "travis" environment, pass package version to skip the check
  TRAVIS_TAG = version;
}
