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
  pname = "asyncio-atexit";
  version = "1.0.1";
  format = "setuptools";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-HQxxVEuO4sSE0yKETucsCHXd5vJQwO1baZNZKrn31DY=";
  };

  nativeBuildInputs = [
    py.setuptools
    py.wheel
  ];

  doCheck = false;
  pythonImportsCheck = [ "asyncio_atexit" ];

  meta = with lib; {
    description = "Like atexit, but for asyncio";
    homepage = "https://github.com/minrk/asyncio-atexit";
    license = licenses.mit;
  };
}
