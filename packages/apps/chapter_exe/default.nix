{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  avisynthplus,
  nix-update-script,
  ...
}:
stdenv.mkDerivation {
  pname = "chapter_exe";
  version = "mod4-unstable-2026-08-11";

  nativeBuildInputs = [ makeWrapper ];

  src = fetchFromGitHub {
    owner = "tobitti0";
    repo = "chapter_exe";
    rev = "266ff66f1052a684552a0a3e962b4b796862b8ac";
    hash = "sha256-iSnKI65q9zItEeWM+0wzcBwsOqcl1akQKbjwkCbFnlU=";
  };

  buildPhase = ''
    runHook preBuild

    make -C src

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -D -m 0755 src/chapter_exe "$out/bin/chapter_exe"
    wrapProgram "$out/bin/chapter_exe" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ avisynthplus ]}"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--flake"
      "--version=branch=master"
    ];
  };

  meta = with lib; {
    description = "Commercial break chapter analysis helper for Amatsukaze";
    homepage = "https://github.com/tobitti0/chapter_exe";
    license = licenses.gpl2Only;
    maintainers = [ ];
    mainProgram = "chapter_exe";
    platforms = platforms.linux;
  };
}
