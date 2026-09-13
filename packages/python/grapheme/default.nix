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
  pname = "grapheme";
  version = "0.6.0";
  format = "setuptools";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-RMK58hu+d8+wWDX+wjC9Q1lUJ1Jn/qGFgBOxAvhgPMo=";
  };

  nativeBuildInputs = [ py.setuptools ];

  doCheck = false;
  pythonImportsCheck = [ "grapheme" ];

  meta = with lib; {
    description = "Unicode grapheme helpers";
    homepage = "https://github.com/alvinlindstam/grapheme";
    license = licenses.mit;
  };
}
