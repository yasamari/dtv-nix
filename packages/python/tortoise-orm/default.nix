{
  lib,
  python3,
  fetchPypi,
  pypika-tortoise,
  ...
}:
let
  py = python3.pkgs;
in
py.buildPythonPackage rec {
  pname = "tortoise-orm";
  version = "0.25.4";
  format = "pyproject";

  src = fetchPypi {
    pname = "tortoise_orm";
    inherit version;
    hash = "sha256-iMIx6+FY8Sh/yclJcxP5pGz7cLZsRYujmQCSGk5S0Bs=";
  };

  nativeBuildInputs = [ py."pdm-backend" ];

  propagatedBuildInputs = [
    pypika-tortoise
    py.iso8601
    py.aiosqlite
    py.anyio
    py.pytz
  ];

  doCheck = false;
  pythonImportsCheck = [ "tortoise" ];

  meta = with lib; {
    description = "Easy async ORM for Python";
    homepage = "https://github.com/tortoise/tortoise-orm";
    license = licenses.asl20;
  };
}
