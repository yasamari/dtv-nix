{
  lib,
  python3,
  fetchFromGitHub,
  ...
}:
let
  py = python3.pkgs;
in
py.buildPythonPackage rec {
  pname = "ariblib";
  version = "0.1.4";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "tsukumijima";
    repo = "ariblib";
    rev = "af6b7127692a4f26310756f09b4c81380fd3d750";
    hash = "sha256-P1JsZwymnenKwH/yiLVa3SU2f3H/A9izZl4tm5w+UNU=";
  };

  nativeBuildInputs = [ py.setuptools ];

  doCheck = false;
  pythonImportsCheck = [ "ariblib" ];

  meta = with lib; {
    description = "Python implementation of ARIB STD-B10/B24";
    homepage = "https://github.com/tsukumijima/ariblib";
    license = licenses.mit;
  };
}
