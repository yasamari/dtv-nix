{ pkgs, ... }:
pkgs.stdenv.mkDerivation {
  pname = "nnedi3";
  version = "avsp-unstable-2025-05-18";

  src = pkgs.fetchFromGitHub {
    owner = "rigaya";
    repo = "NNEDI3";
    rev = "a93dbaea9f0dfc3f6d496a3fe01466bc22dd3a88";
    hash = "sha256-0WRa+pbeasZ15Pd9t3o4lqI3vClDyvR4siWXwlJ8EfM=";
  };

  nativeBuildInputs = with pkgs; [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [ pkgs.avisynthplus ];

  preConfigure = ''
    substituteInPlace nnedi3/meson.build \
      --replace-fail "install_dir : get_option('libdir')" "install_dir : 'lib/avisynth'" \
      --replace-fail "  link_args : link_args," "  link_args : link_args + [ '-Wl,-z,noexecstack' ],"
  '';

  meta = with pkgs.lib; {
    description = "NNEDI3 deinterlacing plugin for AviSynth+";
    homepage = "https://github.com/rigaya/NNEDI3";
    license = licenses.gpl2Plus;
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
  };
}
