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

  patches = [
    (pkgs.fetchpatch {
      url = "https://github.com/tsukumijima/KonomiTV/commit/a4de2c4e2370ffe8ca3ca7781827670e45ceb2b3.patch";
      hash = "sha256-TyJMlXU6zDZmUQ1GSXre2USr+SPWsLWIyESAiMogBxg=";
    })
  ];
  patchFlags = [ "-p2" ];

  nativeBuildInputs = [
    nodejs
    yarn
    pkgs.yarnConfigHook
    pkgs.yarnBuildHook
  ];

  yarnOfflineCache = pkgs.fetchYarnDeps {
    yarnLock = konomitvSrc + "/client/yarn.lock";
    hash = "sha256-XlZJaE8UbKnzMHBVF689niKVnMK51fdFJlEr/1oaeV0=";
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
