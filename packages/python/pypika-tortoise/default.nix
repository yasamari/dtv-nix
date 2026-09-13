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
  pname = "pypika-tortoise";
  version = "0.6.5";
  format = "pyproject";

  src = fetchPypi {
    pname = "pypika_tortoise";
    inherit version;
    hash = "sha256-ZNlsm4hFD2NgrSKnBjkztqkJYacxfwSytjyY/V1wVQY=";
  };

  nativeBuildInputs = [ py."pdm-backend" ];

  doCheck = false;
  pythonImportsCheck = [ "pypika_tortoise" ];

  meta = with lib; {
    description = "PyPika fork streamlined for Tortoise ORM";
    homepage = "https://github.com/tortoise/pypika-tortoise";
    license = licenses.asl20;
  };
}
