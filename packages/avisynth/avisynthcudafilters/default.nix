{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  pkg-config,
  cudaPackages,
  avisynthplus-cuda,
  nix-update-script,
  ...
}:
stdenv.mkDerivation rec {
  pname = "avisynthcudafilters";

  version = "0.7.5";

  src = fetchFromGitHub {
    owner = "rigaya";
    repo = "AviSynthCUDAFilters";
    tag = version;
    hash = "sha256-SuP3BIuPeeJWrC0AMO1rJEriNeC+cksARPNXDeRyRYw=";
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

        substituteInPlace meson.build \
          --replace-fail "cuda_args += [
      '-gencode=arch=compute_50,code=compute_50',
      '-gencode=arch=compute_61,code=compute_61',
      '-gencode=arch=compute_75,code=compute_75',
      '-gencode=arch=compute_86,code=compute_86',
    ]" "if nvcc.version().version_compare('>= 13.0')
      # CUDA 13 dropped Maxwell (compute_50) and Pascal (compute_61)
      cuda_args += [
        '-gencode=arch=compute_75,code=compute_75',
        '-gencode=arch=compute_86,code=compute_86',
      ]
    else
      cuda_args += [
        '-gencode=arch=compute_50,code=compute_50',
        '-gencode=arch=compute_61,code=compute_61',
        '-gencode=arch=compute_75,code=compute_75',
        '-gencode=arch=compute_86,code=compute_86',
      ]
    endif
    # CUDA 13 made __global__ template stubs static and device entities hidden;
    # restore the cross-TU weak-stub behavior this project relies on
    if nvcc.version().version_compare('>= 12.8')
      cuda_args += [
        '-static-global-template-stub=false',
        '-device-entity-has-hidden-visibility=false',
      ]
    endif"
  '';

  postInstall = ''
    mkdir -p $out/lib/avisynth
    for module in $out/lib/*.so*; do
      if [ -e "$module" ]; then
        mv "$module" $out/lib/avisynth/
      fi
    done
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--flake"
      "--version=stable"
    ];
  };

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
