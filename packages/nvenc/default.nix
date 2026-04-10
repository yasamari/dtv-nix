{
  pkgs,
  ...
}:
pkgs.stdenv.mkDerivation rec {
  pname = "nvenc";
  version = "9.14";

  hardeningDisable = [ "all" ];

  src = pkgs.fetchFromGitHub {
    owner = "rigaya";
    repo = "NVEnc";
    tag = version;
    hash = "sha256-SK3RWlkHqmIQYWHkeqWTdH/oHPF/kultxWrQ/Yfe+wI=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = with pkgs; [
    pkg-config
    cargo-c
    git
    wget
  ];

  buildInputs = with pkgs; [
    ffmpeg
    libass
    libdovi
    hdr10plus
    cargo
    libplacebo
    vulkan-headers
    libx11
    cudaPackages.cudatoolkit
    cudaPackages.cuda_cudart
    cudaPackages.libnpp.static
  ];

  configurePhase = ''
    runHook preConfigure

    patchShebangs ./configure

    ./configure \
      --disable-vapoursynth \
      --disable-avisynth \
      --cuda-path="${pkgs.cudaPackages.cudatoolkit}" \
      --extra-cudaldflags="-L${pkgs.cudaPackages.libnpp.static}/lib -L${pkgs.cudaPackages.cuda_cudart}/lib/stubs"

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    make

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -v nvencc $out/bin/

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
