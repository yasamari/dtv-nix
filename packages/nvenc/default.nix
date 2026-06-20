{
  pkgs,
  ...
}:
pkgs.stdenv.mkDerivation rec {
  pname = "nvenc";
  version = "9.17";

  hardeningDisable = [ "all" ];

  src = pkgs.fetchFromGitHub {
    owner = "rigaya";
    repo = "NVEnc";
    tag = version;
    hash = "sha256-oBiW5JtGrgXOtyUmB6t9+Iu0FB9zHd5vDTs+nWPN3Dw=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = with pkgs; [
    meson
    ninja
    pkg-config
  ];

  buildInputs = with pkgs; [
    ffmpeg
    libass
    libdovi
    hdr10plus
    libplacebo
    vulkan-headers
    libx11
    cudaPackages.cudatoolkit
    cudaPackages.cuda_cudart
    cudaPackages.libnpp.static
  ];

  postPatch = ''
    substituteInPlace meson.build \
      --replace-fail \
        "version: run_command('git', 'describe', '--tags', '--abbrev=0', check: true).stdout().strip()," \
        "version: '${version}',"

    # Nix CUDA merged package uses lib/ not lib64/, and has no targets/x86_64-linux/
    substituteInPlace meson.build \
      --replace-fail "cuda_lib_dir = cuda_path / 'lib64'" \
        "cuda_lib_dir = cuda_path / 'lib'" \
      --replace-fail "cuda_target_lib_dir = cuda_path / 'targets' / 'x86_64-linux' / 'lib'" \
        "cuda_target_lib_dir = cuda_path / 'lib'"

    # NPP / culibos are in separate outputs, not in cudatoolkit lib/
    substituteInPlace meson.build \
      --replace-fail \
        "npp_search_dirs = [cuda_target_lib_dir, cuda_lib_dir]" \
        "npp_search_dirs = [cuda_target_lib_dir, cuda_lib_dir, '${pkgs.cudaPackages.libnpp.static}/lib', '${pkgs.cudaPackages.cuda_cudart}/lib']"

    # meson's built-in dependency('cuda') doesn't work with Nix CUDA layout
    substituteInPlace meson.build \
      --replace-fail \
        "cuda_dep = dependency('cuda', version: '>=10.0', required: true)" \
        "cuda_dep = declare_dependency()"
  '';

  configurePhase = ''
    runHook preConfigure

    export CUDA_PATH="${pkgs.cudaPackages.cudatoolkit}"

    meson setup build \
      --buildtype release \
      --prefix "$out" \
      -Dnvenc_cuda_dir="${pkgs.cudaPackages.cudatoolkit}" \
      -Denable_vapoursynth=false \
      -Denable_avisynth=false

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    meson compile -C build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    meson install -C build

    runHook postInstall
  '';

  meta = with pkgs.lib; {
    homepage = "https://github.com/rigaya/NVEnc";
    mainProgram = "nvencc";
    changelog = "https://github.com/rigaya/NVEnc/releases/tag/${src.tag}";
    description = "NVENC high-speed encoding performance experiment tool";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
  };
}
