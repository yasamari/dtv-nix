{ pkgs, ... }:
pkgs.stdenv.mkDerivation {
  pname = "chapter_exe";
  version = "unstable-2025-10-18";

  src = pkgs.fetchFromGitHub {
    owner = "tobitti0";
    repo = "chapter_exe";
    rev = "d74f65ffa6c08066425a1aaa6464f6936ff7254b";
    hash = "sha256-gUXnvB+gTOoshmCQ0rH7n2NhFIXa4jE9V8OHI+b7c14=";
  };

  postPatch = ''
    substituteInPlace src/Makefile \
      --replace-fail '-I../avisynth -I../extras' '-I../avisynth -I../extras -I${pkgs.avisynthplus.dev}/include/avisynth'
  '';

  buildPhase = ''
    runHook preBuild

    make -C src

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -D -m 0755 src/chapter_exe "$out/bin/chapter_exe"

    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "Commercial break chapter analysis helper for Amatsukaze";
    homepage = "https://github.com/tobitti0/chapter_exe";
    license = licenses.gpl2Only;
    maintainers = [ ];
    mainProgram = "chapter_exe";
    platforms = platforms.linux;
  };
}
