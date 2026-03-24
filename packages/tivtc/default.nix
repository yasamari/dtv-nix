{ pkgs, ... }:
pkgs.stdenv.mkDerivation {
  pname = "tivtc";
  version = "1.0.31";

  src = pkgs.fetchFromGitHub {
    owner = "pinterf";
    repo = "TIVTC";
    rev = "2756efd1c337c64d40cfa14aa9ee65599bb41e9f";
    hash = "sha256-bNBOCqz7+yE6U35Gpvx/awmKY+itCX4h3eoTeq70iKg=";
  };

  nativeBuildInputs = [ pkgs.cmake ];

  sourceRoot = "source/src";

  cmakeFlags = [
    "-DCMAKE_INSTALL_LIBDIR=lib"
  ];

  meta = with pkgs.lib; {
    description = "TIVTC and TDeint Avisynth plugins";
    homepage = "https://github.com/pinterf/TIVTC";
    license = licenses.gpl2Plus;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
