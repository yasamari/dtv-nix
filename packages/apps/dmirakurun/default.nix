{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  makeWrapper,
  nodejs_24,
  bash,
  which,
  v4l-utils,
  nix-update-script,
  ...
}:
buildNpmPackage rec {
  pname = "dmirakurun";
  version = "4.1.5-d1";

  src = fetchFromGitHub {
    owner = "jp-dtv-4k";
    repo = "DMirakurun";
    rev = version;
    hash = "sha256-/DY9kJQU6BpH2IrmQG2CqV59MYl1RGaErtkQEA6xrGA=";
  };

  npmDepsHash = "sha256-7vEACKgY4jhazXPa9MU42za5j69a6NIXaC0QkQo9pAM=";

  nativeBuildInputs = [ makeWrapper ];

  prePatch = ''
    sed -i 's/\r$//' src/Mirakurun/config.ts processes.json
  '';

  patches = [ ./nix-filesystem.patch ];

  nodejs = nodejs_24;

  postInstall =
    let
      runtimeDeps = [
        bash
        nodejs_24
        which
        v4l-utils
      ];
      # package.json の name が "dmirakurun" なので、インストール先もそれに合わせる
      appDir = "$out/lib/node_modules/dmirakurun";
      crc32Dir = "${appDir}/node_modules/@node-rs/crc32";
    in
    ''
      rm "$out/bin/mirakurun"

      patch -d ${crc32Dir} -p1 < ${./fix-musl-detection.patch}

      makeWrapper ${nodejs_24}/bin/npm "$out/bin/mirakurun" \
        --chdir "${appDir}" \
        --prefix PATH : ${lib.makeBinPath runtimeDeps}

      wrapProgram "$out/bin/mirakurun-epgdump" \
        --prefix PATH : ${lib.makeBinPath runtimeDeps}
    '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--flake"
      "--version=stable"
    ];
  };

  meta = with lib; {
    description = "Mirakurun fork with mmtsDecoder support for dantto4k (4K broadcast)";
    homepage = "https://github.com/jp-dtv-4k/DMirakurun";
    license = licenses.asl20;
    maintainers = [ ];
    platforms = platforms.linux;
    mainProgram = "mirakurun";
  };
}
