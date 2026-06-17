{ pkgs, ... }:
pkgs.buildNpmPackage rec {
  pname = "mirakurun";
  version = "4.1.0";

  src = pkgs.fetchFromGitHub {
    owner = "Chinachu";
    repo = "Mirakurun";
    rev = "f5307be9b16d13d8e29c2ac04c63d0c17e9ad4b7";
    hash = "sha256-3klXvIRRVNmyUKnSStHGpacEf3ToUEiZi/3S0DBQLkU=";
  };

  npmDepsHash = "sha256-ZTsJjEighSeMpq5+BdbalqbrnuwNTtuk9n5FgvNYz+w=";

  nativeBuildInputs = [
    pkgs.dos2unix
    pkgs.makeWrapper
  ];

  patchPhase = ''
    runHook prePatch
    cp ${./nix-filesystem.patch} ./mirakurun-fix.patch
    unix2dos ./mirakurun-fix.patch
    patch --binary -p1 < ./mirakurun-fix.patch
    runHook postPatch
  '';

  nodejs = pkgs.nodejs_24;

  postInstall =
    let
      runtimeDeps = [
        pkgs.bash
        pkgs.nodejs_24
        pkgs.which
        pkgs.v4l-utils
      ];
      crc32Dir = "$out/lib/node_modules/mirakurun/node_modules/@node-rs/crc32";
    in
    ''
      rm "$out/bin/mirakurun"

      patch -d ${crc32Dir} -p1 < ${./fix-musl-detection.patch}

      makeWrapper ${pkgs.nodejs_24}/bin/npm "$out/bin/mirakurun" \
        --chdir "$out/lib/node_modules/mirakurun" \
        --prefix PATH : ${pkgs.lib.makeBinPath runtimeDeps}

      wrapProgram "$out/bin/mirakurun-epgdump" \
        --prefix PATH : ${pkgs.lib.makeBinPath runtimeDeps}
    '';

  meta = with pkgs.lib; {
    description = "Resource manager for TV tuners";
    homepage = "https://github.com/Chinachu/Mirakurun";
    license = licenses.asl20;
    maintainers = [ ];
    platforms = platforms.linux;
    mainProgram = "mirakurun";
  };
}
