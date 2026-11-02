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
  version = "4.2.1-unstable-2026-11-02";

  src = fetchFromGitHub {
    owner = "Chinachu";
    repo = "Mirakurun";
    rev = "67fc1f811e613a1d655b757387c4a33c66d31d18";
    hash = "sha256-SAHKlpyE7+f/+bGKF4/pQdVHUbub28aHSQKgl4+aAGo=";
  };

  npmDepsHash = "sha256-seQlpPuCUoxf4cuXMwL9gn16gp5c7q7tovUOLc7kAiQ=";

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
