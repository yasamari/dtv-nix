{ pkgs, ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "masktools";
  version = "2.2.30";

  src = pkgs.fetchFromGitHub {
    owner = "pinterf";
    repo = "masktools";
    tag = version;
    hash = "sha256-xetxTBn1WAmsyZ7PG5tcywIFejjFBS3T9Eiy3xaPItQ=";
  };

  nativeBuildInputs = [ pkgs.cmake ];

  postPatch = ''
    substituteInPlace common/functions/functions.cpp \
      --replace-fail '#include <cstring>' $'#include <cstring>\n#include <cstdint>'
  '';

  cmakeFlags = [
    "-DCMAKE_INSTALL_LIBDIR=lib"
  ];

  meta = with pkgs.lib; {
    description = "MaskTools2 Avisynth plugin";
    homepage = "https://github.com/pinterf/masktools";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
