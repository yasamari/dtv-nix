{ pkgs, ... }:
let
  lib = pkgs.lib;
in
pkgs.stdenv.mkDerivation rec {
  pname = "bondriver-linuxmirakc";
  version = "main-2024-10-14";

  src = pkgs.fetchFromGitHub {
    owner = "matching";
    repo = "BonDriver_LinuxMirakc";
    rev = "cfbefc6d21dab4009db5f124984c1b720b76d869";
    hash = "sha256-nEWCuA0BRY7qFNASV4jj0BKRpFXIyJzgI1ch1nyoSQ0=";
    fetchSubmodules = true;
  };

  strictDeps = true;
  dontConfigure = true;

  nativeBuildInputs = [
    pkgs.gnumake
  ];

  buildPhase = ''
    runHook preBuild

    make

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/lib/edcb"

    install -m 0644 BonDriver_LinuxMirakc.so "$out/lib/edcb/BonDriver_LinuxMirakc.so"
    install -m 0644 BonDriver_LinuxMirakc.so.ini_sample "$out/lib/edcb/BonDriver_LinuxMirakc.so.ini"

    runHook postInstall
  '';

  meta = with lib; {
    description = "BonDriver_LinuxMirakc for EDCB";
    homepage = "https://github.com/matching/BonDriver_LinuxMirakc";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
