{ perSystem, pkgs, ... }:
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

      printf '%s\n' \
        '#include <cstdint>' \
        '#include "rgy_codepage.h"' \
        'const char *codepage_str(uint32_t codepage) {' \
        '  switch (codepage) {' \
        '  case CODE_PAGE_SJIS:' \
        '    return "CP932";' \
        '  case CODE_PAGE_EUC_JP:' \
        '    return "EUC-JP";' \
        '  case CODE_PAGE_UTF16_LE:' \
        '    return "UTF16LE";' \
        '  case CODE_PAGE_UTF16_BE:' \
        '    return "UTF16BE";' \
        '  case CODE_PAGE_JIS:' \
        '    return "ISO2022JP";' \
        '  case CODE_PAGE_UTF8:' \
        '    return "UTF-8";' \
        '  default:' \
        '    return nullptr;' \
        '  }' \
        '}' \
        > common/rgy_codepage_compat.cpp

      substituteInPlace common/meson.build \
        --replace-fail "  'rgy_filesystem.cpp'," "  'rgy_filesystem.cpp',
    'rgy_codepage_compat.cpp',"
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
