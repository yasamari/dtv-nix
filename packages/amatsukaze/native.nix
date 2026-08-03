{
  pkgs,
  common,
  ffmpeg,
  avisynthplusCuda,
}:
let
  inherit (common)
    version
    src
    mesonVersionPatch
    ;
in
pkgs.stdenv.mkDerivation {
  pname = "amatsukaze-native";
  inherit version src;

  strictDeps = true;

  nativeBuildInputs = with pkgs; [
    meson
    ninja
    pkg-config
    git
  ];

  buildInputs = [
    ffmpeg
    pkgs.libjpeg_turbo
    pkgs.openssl
    pkgs.zlib
    avisynthplusCuda
  ];

  postPatch = mesonVersionPatch + ''
    substituteInPlace Amatsukaze/AmatsukazeCLI.hpp \
      --replace-fail 'conf.nicoConvChSidPath = pathGetDirectory(conf.nicoConvAssPath) + _T("/ch_sid.txt");' \
                     'tstring nicoConvDir = pathGetDirectory(conf.nicoConvAssPath); conf.nicoConvChSidPath = nicoConvDir.empty() ? moduleDir + _T("/ch_sid.txt") : nicoConvDir + _T("/ch_sid.txt");'

    substituteInPlace Amatsukaze/NicoJK.cpp \
      --replace-fail 'return StringFormat(_T("python3 \"%s\" --channel jk%d --starttime %lld --endtime %lld --width %d --height %d --output \"%s\""),' \
                     'return StringFormat(_T("%s --channel jk%d --starttime %lld --endtime %lld --width %d --height %d --output \"%s\""),'
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

  meta = with pkgs.lib; {
    description = "Native components (libAmatsukaze.so, CLI, GenLogo) for Amatsukaze";
    homepage = "https://github.com/rigaya/Amatsukaze";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
  };
}
