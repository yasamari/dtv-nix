{
  lib,
  python3,
  fetchPypi,
  ...
}:
let
  py = python3.pkgs;
in
py.buildPythonPackage rec {
  pname = "hashids";
  version = "1.3.1";
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-bD3HdeZe/CziwVemWst3bWNMuBRZj0BkaavvAK4/Y1w=";
  };

  nativeBuildInputs = [ py."flit-core" ];

  doCheck = false;
  pythonImportsCheck = [ "hashids" ];

  meta = with lib; {
    description = "Small open-source library that generates short hashes";
    homepage = "https://github.com/davidaurelio/hashids-python";
    license = licenses.mit;
  };
}
