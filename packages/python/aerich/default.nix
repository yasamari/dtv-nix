{
  lib,
  python3,
  fetchPypi,
  tortoise-orm,
  ...
}:
let
  py = python3.pkgs;
in
py.buildPythonPackage rec {
  pname = "aerich";
  version = "0.9.1";
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Ypr771kCY1xB9BDdBd75hMAuBeYtiiAgIQoppKrhkAE=";
  };

  nativeBuildInputs = [ py."poetry-core" ];

  propagatedBuildInputs = [
    tortoise-orm
    py.pydantic
    py.dictdiffer
    py.asyncclick
    py."tomli-w"
  ];

  doCheck = false;
  pythonImportsCheck = [ "aerich" ];

  meta = with lib; {
    description = "Database migrations tool for Tortoise ORM";
    homepage = "https://github.com/tortoise/aerich";
    license = licenses.asl20;
    mainProgram = "aerich";
  };
}
