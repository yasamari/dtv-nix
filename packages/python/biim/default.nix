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
  pname = "biim";
  version = "1.11.0.post1";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "tsukumijima";
    repo = "biim";
    rev = "73dd9b08fd5161f6ea8827e5671fa96e0be57c4d";
    hash = "sha256-EJn3U+0LrIye+cppWmPQ1YV3pswg0vII6WkfV6b2zJI=";
  };

  nativeBuildInputs = [ py.hatchling ];

  propagatedBuildInputs = [ py.aiohttp ];

  doCheck = false;
  pythonImportsCheck = [ "biim" ];

  meta = with lib; {
    description = "LL-HLS implementation written in Python";
    homepage = "https://github.com/tsukumijima/biim";
    license = licenses.mit;
  };
}
