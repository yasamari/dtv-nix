{ avisynthplus, cudaPackages, ... }:
avisynthplus.overrideAttrs (old: {
  pname = "avisynthplus-cuda";

  cmakeFlags = (old.cmakeFlags or [ ]) ++ [
    "-DENABLE_CUDA=ON"
    "-DCUDAToolkit_ROOT=${cudaPackages.cudatoolkit}"
  ];

  buildInputs = (old.buildInputs or [ ]) ++ [
    cudaPackages.cudatoolkit
  ];

  nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
    cudaPackages.cuda_nvcc
  ];

  meta = old.meta // {
    description = "Improved version of the AviSynth frameserver with CUDA support";
    platforms = [ "x86_64-linux" ];
  };
})
