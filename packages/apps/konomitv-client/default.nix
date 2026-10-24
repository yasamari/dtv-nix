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

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = konomitvSrc + "/client/yarn.lock";
    hash = "sha256-wj9/e0lond6Jq7GGJ7R+DrSaQm9QYwP2i45LdHtz0mU=";
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
