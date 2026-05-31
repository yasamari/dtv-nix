{
  pkgs,
  konomitvSrc,
  version,
}:
let
  nodejs = pkgs.nodejs_20;
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

  yarnOfflineCache = pkgs.fetchYarnDeps {
    yarnLock = konomitvSrc + "/client/yarn.lock";
    hash = "sha256-7CnoIm+j1gPGmePv4uevu7jErRZDoxef6cer1gTqUzo=";
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
