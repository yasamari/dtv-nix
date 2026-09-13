{
  lib,
  stdenv,
  callPackage,
  nodejs_22,
  yarn,
  yarnConfigHook,
  yarnBuildHook,
  fetchYarnDeps,
  ...
}:
let
  inherit (callPackage ../konomitv/source.nix { }) konomitvSrc version;

  nodejs = nodejs_22;
  yarn' = yarn.override { inherit nodejs; };
in
stdenv.mkDerivation rec {
  pname = "konomitv-client";
  inherit version;

  src = konomitvSrc;
  sourceRoot = "source/client";

  strictDeps = true;

  nativeBuildInputs = [
    nodejs
    yarn'
    yarnConfigHook
    yarnBuildHook
  ];

  postPatch = ''
    substituteInPlace package.json --replace-fail '"node": "^20.16.0"' '"node": "^22.0.0"'
  '';

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = konomitvSrc + "/client/yarn.lock";
    hash = "sha256-CpVjG1ZVzsbantWgKs8KAxWXoMe5e11FBcVS+kP67gA=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    cp -a dist/. "$out/"

    runHook postInstall
  '';

  meta = with lib; {
    description = "KonomiTV client bundle";
    homepage = "https://github.com/tsukumijima/KonomiTV";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
