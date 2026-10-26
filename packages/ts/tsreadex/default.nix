{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  ...
}:
stdenv.mkDerivation rec {
  pname = "tsreadex";
  version = "master-260428";

  src = fetchFromGitHub {
    owner = "xtne6f";
    repo = "tsreadex";
    rev = version;
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

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--flake"
      "--version=stable"
    ];
  };

  meta = with lib; {
    description = "Extended MPEG-TS stream reader used by EDCB";
    homepage = "https://github.com/xtne6f/tsreadex";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "tsreadex";
    platforms = platforms.linux;
  };
}
