{ pkgs, ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "tsreadex";
  version = "master-240517";

  src = pkgs.fetchFromGitHub {
    owner = "xtne6f";
    repo = "tsreadex";
    rev = version;
    hash = "sha256-k7qq5a2ur/QhOZ+3AWysroRFRH/AY+wM581ahOH5PB8=";
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
    install -D -m 755 tsreadex "$out/bin/tsreadex"
    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "Extended MPEG-TS stream reader used by EDCB";
    homepage = "https://github.com/xtne6f/tsreadex";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "tsreadex";
    platforms = platforms.linux;
  };
}
