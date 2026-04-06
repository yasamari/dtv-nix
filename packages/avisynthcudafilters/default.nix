{ perSystem, pkgs, ... }:
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

  rgyCodepageCompat = pkgs.writeText "rgy_codepage_compat.cpp" ''
    #include <cstdint>
    #include "rgy_codepage.h"

    const char *codepage_str(uint32_t codepage) {
      switch (codepage) {
      case CODE_PAGE_SJIS:
        return "CP932";
      case CODE_PAGE_EUC_JP:
        return "EUC-JP";
      case CODE_PAGE_UTF16_LE:
        return "UTF16LE";
      case CODE_PAGE_UTF16_BE:
        return "UTF16BE";
      case CODE_PAGE_JIS:
        return "ISO2022JP";
      case CODE_PAGE_UTF8:
        return "UTF-8";
      default:
        return nullptr;
      }
    }
  '';
in
pkgs.stdenv.mkDerivation rec {
  pname = "avisynthcudafilters";
  version = "0.7.3";

  src = pkgs.fetchFromGitHub {
    owner = "rigaya";
    repo = "AviSynthCUDAFilters";
    tag = version;
    hash = "sha256-c+RIp8NBAUjNOQDbqYFO52XA03Xszfciwgo5UQr80YQ=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = with pkgs; [
    meson
    ninja
    pkg-config
  ];

  buildInputs = with pkgs; [
    perSystem.self.avisynthplus-cuda
    cudaPackages.cudatoolkit
    cudaPackages.cuda_nvcc
  ];

  env = {
    CUDA_PATH = "${pkgs.cudaPackages.cudatoolkit}";
    CUDACXX = "${pkgs.cudaPackages.cudatoolkit}/bin/nvcc";
  };

  postPatch = ''
      substituteInPlace meson.build \
        --replace-fail "cuda_dep = dependency('cuda', version : '>=11.0', required : true)" "cuda_dep = declare_dependency()"

      cp ${planarFrameCompat} NNEDI3/nnedi3/PlanarFrame_compat.cpp
      cp ${rgyCodepageCompat} common/rgy_codepage_compat.cpp

      substituteInPlace common/meson.build \
        --replace-fail "  'rgy_filesystem.cpp'," "  'rgy_filesystem.cpp',
    'rgy_codepage_compat.cpp',"

      substituteInPlace NNEDI3/nnedi3/meson.build \
        --replace-fail "  'PlanarFrame.cpp'," "  'PlanarFrame.cpp',
    'PlanarFrame_compat.cpp'," \
        --replace-fail "  link_args : link_args," "  link_args : link_args + [ '-Wl,-z,noexecstack' ],"
  '';

  postInstall = ''
    mkdir -p $out/lib/avisynth
    for module in $out/lib/*.so*; do
      if [ -e "$module" ]; then
        mv "$module" $out/lib/avisynth/
      fi
    done
  '';

  meta = with pkgs.lib; {
    description = "CUDA-powered filters for AviSynth+";
    homepage = "https://github.com/rigaya/AviSynthCUDAFilters";
    changelog = "https://github.com/rigaya/AviSynthCUDAFilters/releases/tag/${version}";
    license = [
      licenses.gpl2Plus
      licenses.mit
    ];
    platforms = [ "x86_64-linux" ];
  };
}
