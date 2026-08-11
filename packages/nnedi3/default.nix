{ pkgs, ... }:
pkgs.stdenv.mkDerivation {
  pname = "nnedi3";
  version = "avsp-unstable-2026-08-02";

  src = pkgs.fetchFromGitHub {
    owner = "rigaya";
    repo = "NNEDI3";
    rev = "baa68b771e52e6daf8820531b5172253d4a504ac";
    hash = "sha256-RL/ygwd8DGr+t10CMp5uyksmyO+2ntZx+IJm4UQ6Ysk=";
  };

  nativeBuildInputs = with pkgs; [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [ pkgs.avisynthplus ];

  preConfigure = ''
    substituteInPlace nnedi3/meson.build \
      --replace-fail "install_dir : get_option('libdir')" "install_dir : 'lib/avisynth'"
  '';

  meta = with pkgs.lib; {
    description = "NNEDI3 deinterlacing plugin for AviSynth+";
    homepage = "https://github.com/rigaya/NNEDI3";
    license = licenses.gpl2Plus;
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
  };
}
