{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  dos2unix,
  makeWrapper,
  nodejs_24,
  bash,
  which,
  v4l-utils,
  ...
}:
buildNpmPackage rec {
  pname = "mirakurun";
  version = "4.1.5-unstable-2026-09-26";

  src = fetchFromGitHub {
    owner = "Chinachu";
    repo = "Mirakurun";
    rev = "563a9e703061866c38847f4e5395447afa51ca72";
    hash = "sha256-wrryvWmI3ScqVDYEnDxec4waxu0ClwMEJvV7cD42MvA=";
  };

  npmDepsHash = "sha256-SfdaOaQftZ76K0f+0FvgVE7+vKpQdHdyeB8jl8qVkE8=";

  nativeBuildInputs = [
    dos2unix
    makeWrapper
  ];

  patchPhase = ''
    runHook prePatch
    cp ${./nix-filesystem.patch} ./mirakurun-fix.patch
    unix2dos ./mirakurun-fix.patch
    patch --binary -p1 < ./mirakurun-fix.patch
    runHook postPatch
  '';

  nodejs = nodejs_24;

  postInstall =
    let
      runtimeDeps = [
        bash
        nodejs_24
        which
        v4l-utils
      ];
      crc32Dir = "$out/lib/node_modules/mirakurun/node_modules/@node-rs/crc32";
    in
    ''
      rm "$out/bin/mirakurun"

      patch -d ${crc32Dir} -p1 < ${./fix-musl-detection.patch}

      makeWrapper ${nodejs_24}/bin/npm "$out/bin/mirakurun" \
        --chdir "$out/lib/node_modules/mirakurun" \
        --prefix PATH : ${lib.makeBinPath runtimeDeps}

      wrapProgram "$out/bin/mirakurun-epgdump" \
        --prefix PATH : ${lib.makeBinPath runtimeDeps}
    '';

  meta = with lib; {
    description = "Resource manager for TV tuners";
    homepage = "https://github.com/Chinachu/Mirakurun";
    license = licenses.asl20;
    maintainers = [ ];
    platforms = platforms.linux;
    mainProgram = "mirakurun";
  };
}
