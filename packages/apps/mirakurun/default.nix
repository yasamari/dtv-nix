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
  nix-update-script,
  ...
}:
buildNpmPackage rec {
  pname = "mirakurun";
  version = "4.2.0-unstable-2026-10-31";

  src = fetchFromGitHub {
    owner = "Chinachu";
    repo = "Mirakurun";
    rev = "6e8ab686ae6b714cba14e671544a4a7d90be5486";
    hash = "sha256-As4KjZQ+N3pqwnJtXForMTpjaenwaOPENf+E7Ev/SxU=";
  };

  npmDepsHash = "sha256-eTcE+W2NLwBGqi0OcmbAKOUhCwGiQXsKQGbQFIFAfSY=";

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

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--flake"
      "--version=branch=master"
    ];
  };

  meta = with lib; {
    description = "Resource manager for TV tuners";
    homepage = "https://github.com/Chinachu/Mirakurun";
    license = licenses.asl20;
    maintainers = [ ];
    platforms = platforms.linux;
    mainProgram = "mirakurun";
  };
}
