{
  lib,
  stdenv,
  fetchFromGitHub,
  gnumake,
  nix-update-script,
  ...
}:
stdenv.mkDerivation rec {
  pname = "bondriver-linuxmirakc";
  version = "0-unstable-2026-11-14";

  src = fetchFromGitHub {
    owner = "matching";
    repo = "BonDriver_LinuxMirakc";
    rev = "8d74b60db5112bf035e5f85f8a182d24f2480c75";
    hash = "sha256-AFRMzD1J2jbnxh2zPLR4OaBkZApMAsq0OYf4kh8Eadc=";
    fetchSubmodules = true;
  };

  strictDeps = true;
  dontConfigure = true;

  nativeBuildInputs = [
    gnumake
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

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--flake"
      "--version=branch=main"
    ];
  };

  meta = with lib; {
    description = "BonDriver_LinuxMirakc for EDCB";
    homepage = "https://github.com/matching/BonDriver_LinuxMirakc";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
