{
  lib,
  python3,
  fetchFromGitHub,
  nix-update-script,
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
    rev = "v${version}";
    hash = "sha256-P1JsZwymnenKwH/yiLVa3SU2f3H/A9izZl4tm5w+UNU=";
  };

  nativeBuildInputs = [ py.setuptools ];

  doCheck = false;
  pythonImportsCheck = [ "ariblib" ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--flake"
      "--version=stable"
    ];
  };

  meta = with lib; {
    description = "Python implementation of ARIB STD-B10/B24";
    homepage = "https://github.com/tsukumijima/ariblib";
    license = licenses.mit;
  };
}
