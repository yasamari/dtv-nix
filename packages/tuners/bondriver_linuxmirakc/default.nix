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
  version = "0-unstable-2026-11-07";

  src = fetchFromGitHub {
    owner = "matching";
    repo = "BonDriver_LinuxMirakc";
    rev = "bc1d70c7415ea5b49b8384151045b0c826fded5c";
    hash = "sha256-NFoujpjB5EALbdMg0NAO+Wzgvz6JWss1GArH4dn/Kac=";
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
