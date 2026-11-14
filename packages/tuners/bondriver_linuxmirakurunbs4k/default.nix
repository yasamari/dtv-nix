{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
}:
stdenv.mkDerivation {
  pname = "bondriver-linuxmirakurunbs4k";
  version = "0-unstable-2026-08-01";

  src = fetchFromGitHub {
    owner = "MistVVK";
    repo = "BonDriver_LinuxMirakurunBS4K";
    rev = "405d8e33c96d6f6f6c45159f4ad21a1067009d6d";
    hash = "sha256-0w12gpcLqnA7M5nwfGVYOKvrKdVpDpj18Eowco1QvQE=";
    fetchSubmodules = true;
  };

  strictDeps = true;
  dontConfigure = true;

  enableParallelBuilding = true;

  installPhase = ''
    runHook preInstall

    # EDCB は BonDriver と同じディレクトリの <name>.so.ini を読む
    install -Dm755 BonDriver_LinuxMirakurunBS4K.so \
      "$out/lib/edcb/BonDriver_LinuxMirakurunBS4K.so"
    install -Dm644 sample/BonDriver_LinuxMirakurunBS4K.so.ini \
      "$out/lib/edcb/BonDriver_LinuxMirakurunBS4K.so.ini"

    # ChSet4 / ChSet5 は既存環境とのマージが必要なため、サンプルとして別置き
    install -Dm644 "sample/BonDriver_LinuxMirakurunBS4K(LinuxMirakurunBS4K).ChSet4.txt" \
      "$out/share/bondriver-linuxmirakurunbs4k/sample/BonDriver_LinuxMirakurunBS4K(LinuxMirakurunBS4K).ChSet4.txt"
    install -Dm644 sample/ChSet5.txt \
      "$out/share/bondriver-linuxmirakurunbs4k/sample/ChSet5.txt"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--flake"
      "--version=branch=main"
    ];
  };

  meta = {
    description = "BonDriver for EDCB on Linux to receive BS4K channels via Mirakurun/mirakc";
    homepage = "https://github.com/MistVVK/BonDriver_LinuxMirakurunBS4K";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
}
