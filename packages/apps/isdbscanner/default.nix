{
  lib,
  python3,
  fetchFromGitHub,
  libusb1,
  ariblib,
  recisdb,
  ...
}:

let
  py = python3.pkgs;
in
py.buildPythonApplication rec {
  pname = "isdb-scanner";
  version = "1.3.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "tsukumijima";
    repo = "ISDBScanner";
    rev = "v${version}";
    hash = "sha256-FjGVrfcQX24EckdUW9xEo45bCbxDjeOzPRVWqCW0cIE=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'devtools = ">=0.12.0"' "" \
      --replace-fail 'libusb-package = ">=1.0.26"' ""

    substituteInPlace isdb_scanner/tuner.py \
      --replace-fail 'import libusb_package' 'import usb.backend.libusb1' \
      --replace-fail 'backend = libusb_package.get_libusb1_backend()' 'backend = usb.backend.libusb1.get_backend(find_library=lambda _: "${lib.getLib libusb1}/lib/libusb-1.0.so")'

    python - <<'PY'
    from pathlib import Path

    path = Path("isdb_scanner/__main__.py")
    text = path.read_text()
    text = text.replace(
        "if __name__ == '__main__':\n    app()\n",
        "def run() -> None:\n    app()\n\n\nif __name__ == '__main__':\n    run()\n",
    )
    path.write_text(text)
    PY

    cat >> pyproject.toml <<'EOF'

    [tool.poetry.scripts]
    isdb-scanner = "isdb_scanner.__main__:run"
    EOF
  '';

  build-system = [ py."poetry-core" ];

  dependencies = [
    ariblib
    py.pydantic
    py.pyusb
    py.rich
    py."ruamel-yaml"
    py.typer
    py."typing-extensions"
  ];

  makeWrapperArgs = [
    "--unset PYTHONPATH"
    "--unset PYTHONHOME"
    "--unset PYTHONSTARTUP"
    "--unset _PYTHON_HOST_PLATFORM"
    "--unset _PYTHON_SYSCONFIGDATA_NAME"

    "--prefix PATH : ${lib.makeBinPath [ recisdb ]}"
  ];

  doCheck = false;

  pythonImportsCheck = [ "isdb_scanner" ];

  meta = with lib; {
    description = "Automatic scanner for Japanese TV broadcast channels (ISDB-T/ISDB-S)";
    homepage = "https://github.com/tsukumijima/ISDBScanner";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "isdb-scanner";
    platforms = platforms.linux;
  };
}
