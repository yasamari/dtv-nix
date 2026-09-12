{ perSystem, pkgs, ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "avisynthcudafilters";
  version = "0.7.4";

  src = pkgs.fetchFromGitHub {
    owner = "rigaya";
    repo = "AviSynthCUDAFilters";
    tag = version;
    hash = "sha256-4js3yo4S8bADFS2H0Nkjvg+EoHtz52KsLevXWX6+dQM=";
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
