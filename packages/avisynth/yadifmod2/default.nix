{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  avisynthplus,
  ...
}:
let
  cmakeInstallPrefix = "$" + "{CMAKE_INSTALL_PREFIX}";
  cmakeVersionVar = "$" + "{ver}";
in
stdenv.mkDerivation rec {
  pname = "yadifmod2";
  version = "0.2.8";

  src = fetchFromGitHub {
    owner = "Asd-g";
    repo = "yadifmod2";
    tag = version;
    hash = "sha256-Z21GZjTOGAGhzMZ1dp5H0AtwW+7I/JiQK8f4jJ0EEhM=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ avisynthplus ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail '${cmakeInstallPrefix}/include/avisynth' '${avisynthplus.dev}/include/avisynth' \
      --replace-fail '/usr/local/include/avisynth' '${avisynthplus.dev}/include/avisynth' \
      --replace-fail 'OUTPUT_NAME "yadifmod2.${cmakeVersionVar}"' 'OUTPUT_NAME "yadifmod2"'
  '';

  cmakeFlags = [
    "-DCMAKE_INSTALL_LIBDIR=lib"
  ];

  meta = with lib; {
    description = "YADIF Avisynth plugin for Linux";
    homepage = "https://github.com/Asd-g/yadifmod2";
    license = licenses.gpl2Only;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
