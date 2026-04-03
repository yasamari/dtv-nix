{ pkgs, ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "psisimux";
  version = "master-250405";

  src = pkgs.fetchFromGitHub {
    owner = "xtne6f";
    repo = "psisimux";
    rev = "1a01a38886dc41bac81d547ba31fa9eef1bad46b";
    hash = "sha256-omBkpFz8AXDqpNMa+8g3SdomUMVy8H/1PbEHJQTvbcI=";
  };

  strictDeps = true;
  dontConfigure = true;

  buildPhase = ''
    runHook preBuild
    make
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -D -m 755 psisimux "$out/bin/psisimux"
    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "Multiplex PSI/SI archive and subtitles into MPEG-4";
    homepage = "https://github.com/xtne6f/psisimux";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "psisimux";
    platforms = platforms.linux;
  };
}
