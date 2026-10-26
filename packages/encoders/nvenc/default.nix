{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  pkg-config,
  ffmpeg,
  fontconfig,
  freetype,
  fribidi,
  glib,
  harfbuzz,
  libsysprof-capture,
  pcre2,
  libass,
  libdovi,
  hdr10plus,
  libplacebo,
  vulkan-headers,
  libx11,
  cudaPackages,
  nix-update-script,
  ...
}:
stdenv.mkDerivation rec {
  pname = "nvenc";
  version = "9.39";

  hardeningDisable = [ "all" ];

  src = fetchFromGitHub {
    owner = "rigaya";
    repo = "NVEnc";
    tag = version;
    hash = "sha256-/ToIic0xitDwRPbz88r3c/L+5YMLr3YcL39kGBRxLX0=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    ffmpeg
    fontconfig
    freetype
    fribidi
    glib
    harfbuzz
    libsysprof-capture
    pcre2
    libass
    libdovi
    hdr10plus
    libplacebo
    vulkan-headers
    libx11
    cudaPackages.cudatoolkit
    cudaPackages.cuda_cudart
    cudaPackages.libnpp.static
    cudaPackages.cuda_culibos
  ];

  postPatch = ''
    substituteInPlace meson.build \
      --replace-fail \
        "version: run_command('sh', 'scripts/get-version.sh', check: true).stdout().strip()," \
        "version: '${version}',"

    # Nix CUDA merged package uses lib/ not lib64/, and has no targets/<triple>/
    substituteInPlace meson.build \
      --replace-fail "cuda_lib_dir = cuda_path / 'lib64'" \
        "cuda_lib_dir = cuda_path / 'lib'" \
      --replace-fail "cuda_target_lib_dir = cuda_path / 'targets' / cuda_target_name / 'lib'" \
        "cuda_target_lib_dir = cuda_path / 'lib'"

    # NPP / culibos are in separate outputs, not in cudatoolkit lib/
    substituteInPlace meson.build \
      --replace-fail \
        "npp_search_dirs = [cuda_target_lib_dir, cuda_lib_dir]" \
        "npp_search_dirs = [cuda_target_lib_dir, cuda_lib_dir, '${cudaPackages.libnpp.static}/lib', '${cudaPackages.cuda_cudart}/lib', '${cudaPackages.cuda_culibos}/lib']"

    # meson requires all NPP libs (incl. culibos) in one directory, which never
    # matches the split Nix CUDA outputs, so no -L is emitted. Without it, nvcc's
    # device-link step cannot find the NPP static archives and fails with
    # undefined __cudaRegisterLinkedBinary_* symbols.
    substituteInPlace meson.build \
      --replace-fail \
        "and fs.exists(dir / 'libnppc_static.a') and fs.exists(dir / 'libculibos.a')" \
        "and fs.exists(dir / 'libnppc_static.a')"

    substituteInPlace meson.build \
      --replace-fail \
        "npp_deps = declare_dependency(link_args: ['-L' + npp_lib_dir, '-lnppif_static', '-lnppig_static', '-lnppc_static', '-lculibos'])" \
        "npp_deps = declare_dependency(link_args: ['-L' + npp_lib_dir, '-L' + '${cudaPackages.cuda_culibos}/lib', '-lnppif_static', '-lnppig_static', '-lnppc_static', '-lculibos'])"

    # meson's built-in dependency('cuda') doesn't work with Nix CUDA layout
    substituteInPlace meson.build \
      --replace-fail \
        "cuda_dep = dependency('cuda', version: '>=10.0', required: true)" \
        "cuda_dep = declare_dependency()"
  '';

  configurePhase = ''
    runHook preConfigure

    export CUDA_PATH="${cudaPackages.cudatoolkit}"

    meson setup build \
      --buildtype release \
      --prefix "$out" \
      -Dnvenc_cuda_dir="${cudaPackages.cudatoolkit}" \
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

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--flake"
      "--version=stable"
    ];
  };

  meta = with lib; {
    homepage = "https://github.com/rigaya/NVEnc";
    mainProgram = "nvencc";
    changelog = "https://github.com/rigaya/NVEnc/releases/tag/${src.tag}";
    description = "NVENC high-speed encoding performance experiment tool";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
  };
}
