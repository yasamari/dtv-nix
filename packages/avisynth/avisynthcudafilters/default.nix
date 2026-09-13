{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  pkg-config,
  cudaPackages,
  avisynthplus-cuda,
  ...
}:
stdenv.mkDerivation rec {
  pname = "avisynthcudafilters";
  version = "0.7.4";

  src = fetchFromGitHub {
    owner = "rigaya";
    repo = "AviSynthCUDAFilters";
    tag = version;
    hash = "sha256-4js3yo4S8bADFS2H0Nkjvg+EoHtz52KsLevXWX6+dQM=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    cudaPackages.cudatoolkit
    cudaPackages.cuda_nvcc
  ]
  ++ [ avisynthplus-cuda ];

  env = {
    CUDA_PATH = "${cudaPackages.cudatoolkit}";
    CUDACXX = "${cudaPackages.cudatoolkit}/bin/nvcc";
  };

  postPatch = ''
    substituteInPlace meson.build \
      --replace-fail "cuda_dep = dependency('cuda', version : '>=11.0', required : true, static : true)" "cuda_dep = declare_dependency()"
  '';

  postInstall = ''
    mkdir -p $out/lib/avisynth
    for module in $out/lib/*.so*; do
      if [ -e "$module" ]; then
        mv "$module" $out/lib/avisynth/
      fi
    done
  '';

  meta = with lib; {
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
