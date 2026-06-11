{
  pkgs,
  konomitvSrc,
  version,
}:
let
  nodejs = pkgs.nodejs_22;
  yarn = pkgs.yarn.override { inherit nodejs; };
in
pkgs.stdenv.mkDerivation rec {
  pname = "konomitv-client";
  inherit version;

  src = konomitvSrc;
  sourceRoot = "source/client";

  strictDeps = true;

  nativeBuildInputs = [
    nodejs
    yarn
    pkgs.yarnConfigHook
    pkgs.yarnBuildHook
  ];

  postPatch = ''
    substituteInPlace package.json --replace-fail '"node": "^20.16.0"' '"node": "^22.0.0"'
  '';

  yarnOfflineCache = pkgs.fetchYarnDeps {
    yarnLock = konomitvSrc + "/client/yarn.lock";
    hash = "sha256-ynyOZVqWU0KjQL94fmECrRRGeSr/lC4Q3L1gmSoF1RU=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    cp -a dist/. "$out/"

    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "KonomiTV client bundle";
    homepage = "https://github.com/tsukumijima/KonomiTV";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
