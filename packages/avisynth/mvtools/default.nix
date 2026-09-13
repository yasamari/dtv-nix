{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fftwFloat,
  ...
}:
stdenv.mkDerivation rec {
  pname = "mvtools";
  version = "2.7.47";

  src = fetchFromGitHub {
    owner = "pinterf";
    repo = "mvtools";
    tag = version;
    hash = "sha256-G3/xsfzgtDY3AHiF0N4mfTio9XsD54LYvfi4UTIPngI=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ fftwFloat ];

  cmakeFlags = [
    "-DCMAKE_INSTALL_LIBDIR=lib"
  ];

  meta = with lib; {
    description = "MVTools, DePan, and DePanEstimate Avisynth plugins";
    homepage = "https://github.com/pinterf/mvtools";
    license = licenses.gpl2Plus;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
