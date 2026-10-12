{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ...
}:
stdenv.mkDerivation rec {
  pname = "tivtc";
  version = "1.0.32";

  src = fetchFromGitHub {
    owner = "pinterf";
    repo = "TIVTC";
    tag = "v${version}";
    hash = "sha256-CFUkJNUv5bJAt31btjE3A221tAR82bjTJBkI0M83+CA=";
  };

  nativeBuildInputs = [ cmake ];

  sourceRoot = "source/src";

  cmakeFlags = [
    "-DCMAKE_INSTALL_LIBDIR=lib"
  ];

  meta = with lib; {
    description = "TIVTC and TDeint Avisynth plugins";
    homepage = "https://github.com/pinterf/TIVTC";
    license = licenses.gpl2Plus;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
