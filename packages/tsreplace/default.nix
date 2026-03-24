{ pkgs, ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "tsreplace";
  version = "0.19";

  hardeningDisable = [ "format" ];

  src = pkgs.fetchFromGitHub {
    owner = "rigaya";
    repo = "tsreplace";
    tag = version;
    hash = "sha256-LIz237ngKpLVWkHtOv+V5i5xIi3Y1v1NLG4T52qO0aA=";
  };

  nativeBuildInputs = with pkgs; [
    pkg-config
    git
  ];

  buildInputs = with pkgs; [
    ffmpeg
  ];

  configurePhase = ''
    runHook preConfigure

    patchShebangs ./configure
    ./configure --prefix=$out --cxx=$CXX

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    make

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    make install

    runHook postInstall
  '';

  meta = with pkgs.lib; {
    homepage = "https://github.com/rigaya/tsreplace";
    mainProgram = "tsreplace";
    changelog = "https://github.com/rigaya/tsreplace/releases/tag/${src.tag}";
    description = "Replace TS video stream with re-encoded video while preserving other packets";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
  };
}
