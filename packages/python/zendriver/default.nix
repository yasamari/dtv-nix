{
  lib,
  python3,
  fetchPypi,
  asyncio-atexit,
  grapheme,
  ...
}:
let
  py = python3.pkgs;
in
py.buildPythonPackage rec {
  pname = "zendriver";
  version = "0.15.3";
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-g8OP4XSJNw8MOB37iw1NC7n153VcV0jJnXK/mIb1nu4=";
  };

  nativeBuildInputs = [ py.hatchling ];

  propagatedBuildInputs = [
    asyncio-atexit
    py.deprecated
    py.emoji
    grapheme
    py.mss
    py.websockets
  ];

  doCheck = false;
  pythonImportsCheck = [ "zendriver" ];

  meta = with lib; {
    description = "Async browser automation via Chrome DevTools Protocol";
    homepage = "https://github.com/cdpdriver/zendriver";
    license = licenses.agpl3Only;
  };
}
