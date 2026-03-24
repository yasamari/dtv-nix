{ pkgs, ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "psisiarc";
  version = "master-230324";

  src = pkgs.fetchFromGitHub {
    owner = "xtne6f";
    repo = "psisiarc";
    rev = version;
    hash = "sha256-ToSB+6NQLQQseE7sOQXs7uoNJMIZAZTkpuJpMb8dFqg=";
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
    install -D -m 755 psisiarc "$out/bin/psisiarc"
    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "Archive PSI/SI tables from MPEG-TS streams";
    homepage = "https://github.com/xtne6f/psisiarc";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "psisiarc";
    platforms = platforms.linux;
  };
}
