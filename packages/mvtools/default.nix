{ pkgs, ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "mvtools";
  version = "2.7.46";

  src = pkgs.fetchFromGitHub {
    owner = "pinterf";
    repo = "mvtools";
    tag = version;
    hash = "sha256-7KQgr/zVsa4IHs9KvwpILA+Lr6O0ybhy79cDV53Um3U=";
  };

  nativeBuildInputs = [ pkgs.cmake ];
  buildInputs = [ pkgs.fftwFloat ];

  cmakeFlags = [
    "-DCMAKE_INSTALL_LIBDIR=lib"
  ];

  meta = with pkgs.lib; {
    description = "MVTools, DePan, and DePanEstimate Avisynth plugins";
    homepage = "https://github.com/pinterf/mvtools";
    license = licenses.gpl2Plus;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
