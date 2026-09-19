{
  lib,
  stdenv,
  callPackage,
  meson,
  ninja,
  pkg-config,
  git,
  libjpeg_turbo,
  openssl,
  zlib,
  ffmpeg,
  avisynthplus-cuda,
}:
let
  avisynthplusCuda = avisynthplus-cuda;
  common = callPackage ../amatsukaze/common.nix { };
  inherit (common)
    version
    src
    mesonVersionPatch
    ;
in
stdenv.mkDerivation {
  pname = "amatsukaze-native";
  inherit version src;

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    git
  ];

  buildInputs = [
    ffmpeg
    libjpeg_turbo
    openssl
    zlib
    avisynthplusCuda
  ];

  postPatch = mesonVersionPatch + ''
    substituteInPlace Amatsukaze/AmatsukazeCLI.hpp \
      --replace-fail 'conf.nicoConvChSidPath = pathGetDirectory(nicoJKToolPath) + _T("/ch_sid.txt");' \
                     'tstring nicoConvDir = pathGetDirectory(nicoJKToolPath); conf.nicoConvChSidPath = nicoConvDir.empty() ? moduleDir + _T("/ch_sid.txt") : nicoConvDir + _T("/ch_sid.txt");'
  '';

  configurePhase = ''
    runHook preConfigure
    meson setup build --buildtype release
    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild
    ninja -C build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 build/Amatsukaze/libAmatsukaze.so "$out/lib/libAmatsukaze.so"
    install -Dm755 build/AmatsukazeCLI/AmatsukazeCLI "$out/bin/AmatsukazeCLI"
    install -Dm755 build/AmatsukazeGenLogo/AmatsukazeGenLogo "$out/bin/AmatsukazeGenLogo"
    runHook postInstall
  '';

  meta = with lib; {
    description = "Native components (libAmatsukaze.so, CLI, GenLogo) for Amatsukaze";
    homepage = "https://github.com/rigaya/Amatsukaze";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
  };
}
