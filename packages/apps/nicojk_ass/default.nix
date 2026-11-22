{
  lib,
  python3,
  fetchFromGitHub,
  nix-update-script,
}:
let
  py = python3.pkgs;
in
py.buildPythonApplication rec {
  pname = "nicojk_ass";
  version = "0.01";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "rigaya";
    repo = "nicojk_ass";
    rev = version;
    hash = "sha256-qNA3/W6ftDu79YqflyHw5B5kz+JUCGDzuP/tvTr4sKA=";
  };

  nativeBuildInputs = [ py.setuptools ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--flake"
      "--version=stable"
    ];
  };

  meta = with lib; {
    description = "Generate ASS subtitles from Nico Nico Jikkyo comments";
    homepage = "https://github.com/rigaya/nicojk_ass";
    # The package itself is MIT, but it vendors danmaku2ass.py (GPL-3.0).
    license = with licenses; [
      mit
      gpl3Only
    ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "nicojk_ass";
  };
}
