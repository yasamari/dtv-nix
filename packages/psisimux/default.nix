{ pkgs, ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "psisimux";
  version = "master-260422";

  src = pkgs.fetchFromGitHub {
    owner = "xtne6f";
    repo = "psisimux";
    rev = version;
    hash = "sha256-A8GPEZNqUGZaQ4p+WhUQYjhEoHNfoXPkxBZ+C/I9dj0=";
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
