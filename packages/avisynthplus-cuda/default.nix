{ pkgs, ... }:
pkgs.avisynthplus.overrideAttrs (old: {
  pname = "avisynthplus-cuda";

  cmakeFlags = (old.cmakeFlags or [ ]) ++ [
    "-DENABLE_CUDA=ON"
    "-DCUDAToolkit_ROOT=${pkgs.cudaPackages.cudatoolkit}"
  ];

  buildInputs = (old.buildInputs or [ ]) ++ [
    pkgs.cudaPackages.cudatoolkit
  ];

  nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
    pkgs.cudaPackages.cuda_nvcc
  ];

  meta = old.meta // {
    description = "Improved version of the AviSynth frameserver with CUDA support";
    platforms = [ "x86_64-linux" ];
  };
})
