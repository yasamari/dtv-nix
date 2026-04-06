{ pkgs, ... }:
let
  planarFrameCompat = pkgs.writeText "PlanarFrame_compat.cpp" ''
    #include <cstdint>

    static inline void convYUY2to422_scalar(
      const uint8_t *src,
      uint8_t *py,
      uint8_t *pu,
      uint8_t *pv,
      int pitch1,
      int pitch2Y,
      int pitch2UV,
      int width,
      int height
    ) {
      if (width <= 0 || height <= 0) {
        return;
      }

      const int halfWidth = width >> 1;
      for (int y = 0; y < height; ++y) {
        for (int x = 0; x < halfWidth; ++x) {
          const int s = x * 4;
          const int yy = x * 2;
          py[yy] = src[s];
          pu[x] = src[s + 1];
          py[yy + 1] = src[s + 2];
          pv[x] = src[s + 3];
        }
        src += pitch1;
        py += pitch2Y;
        pu += pitch2UV;
        pv += pitch2UV;
      }
    }

    static inline void conv422toYUY2_scalar(
      uint8_t *py,
      uint8_t *pu,
      uint8_t *pv,
      uint8_t *dst,
      int pitch1Y,
      int pitch1UV,
      int pitch2,
      int width,
      int height
    ) {
      if (width <= 0 || height <= 0) {
        return;
      }

      const int halfWidth = width >> 1;
      for (int y = 0; y < height; ++y) {
        for (int x = 0; x < halfWidth; ++x) {
          const int d = x * 4;
          const int yy = x * 2;
          dst[d] = py[yy];
          dst[d + 1] = pu[x];
          dst[d + 2] = py[yy + 1];
          dst[d + 3] = pv[x];
        }
        py += pitch1Y;
        pu += pitch1UV;
        pv += pitch1UV;
        dst += pitch2;
      }
    }

    extern "C" void convYUY2to422_MMX(
      const uint8_t *src,
      uint8_t *py,
      uint8_t *pu,
      uint8_t *pv,
      int pitch1,
      int pitch2Y,
      int pitch2UV,
      int width,
      int height
    ) {
      convYUY2to422_scalar(src, py, pu, pv, pitch1, pitch2Y, pitch2UV, width, height);
    }

    extern "C" void convYUY2to422_SSE2(
      const uint8_t *src,
      uint8_t *py,
      uint8_t *pu,
      uint8_t *pv,
      int pitch1,
      int pitch2Y,
      int pitch2UV,
      int width,
      int height
    ) {
      convYUY2to422_scalar(src, py, pu, pv, pitch1, pitch2Y, pitch2UV, width * 8, height);
    }

    extern "C" void convYUY2to422_AVX(
      const uint8_t *src,
      uint8_t *py,
      uint8_t *pu,
      uint8_t *pv,
      int pitch1,
      int pitch2Y,
      int pitch2UV,
      int width,
      int height
    ) {
      convYUY2to422_scalar(src, py, pu, pv, pitch1, pitch2Y, pitch2UV, width * 8, height);
    }

    extern "C" void conv422toYUY2_MMX(
      uint8_t *py,
      uint8_t *pu,
      uint8_t *pv,
      uint8_t *dst,
      int pitch1Y,
      int pitch1UV,
      int pitch2,
      int width,
      int height
    ) {
      conv422toYUY2_scalar(py, pu, pv, dst, pitch1Y, pitch1UV, pitch2, width, height);
    }

    extern "C" void conv422toYUY2_SSE2(
      uint8_t *py,
      uint8_t *pu,
      uint8_t *pv,
      uint8_t *dst,
      int pitch1Y,
      int pitch1UV,
      int modulo2,
      int width,
      int height
    ) {
      const int pitch2 = modulo2 + (width << 4);
      conv422toYUY2_scalar(py, pu, pv, dst, pitch1Y, pitch1UV, pitch2, width * 8, height);
    }

    extern "C" void conv422toYUY2_AVX(
      uint8_t *py,
      uint8_t *pu,
      uint8_t *pv,
      uint8_t *dst,
      int pitch1Y,
      int pitch1UV,
      int modulo2,
      int width,
      int height
    ) {
      const int pitch2 = modulo2 + (width << 4);
      conv422toYUY2_scalar(py, pu, pv, dst, pitch1Y, pitch1UV, pitch2, width * 8, height);
    }
  '';
in
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
    cp ${planarFrameCompat} nnedi3/PlanarFrame_compat.cpp

    substituteInPlace nnedi3/meson.build \
      --replace-fail "install_dir : get_option('libdir')" "install_dir : 'lib/avisynth'" \
      --replace-fail "  'PlanarFrame.cpp'," "  'PlanarFrame.cpp',
    'PlanarFrame_compat.cpp'," \
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
