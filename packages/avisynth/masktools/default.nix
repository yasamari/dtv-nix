{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  nix-update-script,
  ...
}:
stdenv.mkDerivation rec {
  pname = "masktools";
  version = "2.3";

  src = fetchFromGitHub {
    owner = "pinterf";
    repo = "masktools";
    tag = version;
    hash = "sha256-44CnQk40wA4Pe37CviD+33pYP9m51atDj6MZo8M+L9c=";
  };

  nativeBuildInputs = [ cmake ];

  postPatch = ''
    substituteInPlace common/functions/functions.cpp \
      --replace-fail '#include <cstring>' $'#include <cstring>\n#include <cstdint>'
  '';

  cmakeFlags = [
    "-DCMAKE_INSTALL_LIBDIR=lib"
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--flake"
      "--version=stable"
    ];
  };

  meta = with lib; {
    description = "MaskTools2 Avisynth plugin";
    homepage = "https://github.com/pinterf/masktools";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
