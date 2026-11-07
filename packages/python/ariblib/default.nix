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
  version = "0.2.0";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "tsukumijima";
    repo = "ariblib";
    rev = "v${version}";
    hash = "sha256-jF5NnOSiV2MbZ2jkK++sVqCRwNxj8V+kLfvOPEX0uc8=";
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
