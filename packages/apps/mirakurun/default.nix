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
  version = "4.3.0-unstable-2026-11-06";

  src = fetchFromGitHub {
    owner = "Chinachu";
    repo = "Mirakurun";
    rev = "de689eed6a55a4c605e653f5630915b3235888fb";
    hash = "sha256-d0GkFBDQ+8ErVp5z3VEupqApQg2jRfooaKkVEGxX+jc=";
  };

  npmDepsHash = "sha256-epl1H5929BO/JduHTWtNhjmTF/kGspHNp26rS1dDIzE=";

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
