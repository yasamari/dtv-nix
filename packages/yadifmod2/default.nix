{ pkgs, ... }:
let
  cmakeInstallPrefix = "$" + "{CMAKE_INSTALL_PREFIX}";
  cmakeVersionVar = "$" + "{ver}";
in
pkgs.stdenv.mkDerivation rec {
  pname = "yadifmod2";
  version = "0.2.8";

  src = pkgs.fetchFromGitHub {
    owner = "Asd-g";
    repo = "yadifmod2";
    tag = version;
    hash = "sha256-Z21GZjTOGAGhzMZ1dp5H0AtwW+7I/JiQK8f4jJ0EEhM=";
  };

  nativeBuildInputs = [ pkgs.cmake ];
  buildInputs = [ pkgs.avisynthplus ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail '${cmakeInstallPrefix}/include/avisynth' '${pkgs.avisynthplus.dev}/include/avisynth' \
      --replace-fail '/usr/local/include/avisynth' '${pkgs.avisynthplus.dev}/include/avisynth' \
      --replace-fail 'OUTPUT_NAME "yadifmod2.${cmakeVersionVar}"' 'OUTPUT_NAME "yadifmod2"'
  '';

  cmakeFlags = [
    "-DCMAKE_INSTALL_LIBDIR=lib"
  ];

  meta = with pkgs.lib; {
    description = "YADIF Avisynth plugin for Linux";
    homepage = "https://github.com/Asd-g/yadifmod2";
    license = licenses.gpl2Only;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
