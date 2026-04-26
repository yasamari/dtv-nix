{ pkgs, ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "tsreadex";
  version = "master-a82528c";

  src = pkgs.fetchFromGitHub {
    owner = "xtne6f";
    repo = "tsreadex";
    rev = "a82528ccb698fcd07b4da1bb2243e63d685c34a7";
    hash = "sha256-jszkLID4J0ECs688bj9qlntjZ7NHYi6fPRB1HR2acos=";
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
