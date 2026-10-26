{
  lib,
  rustPlatform,
  fetchFromGitHub,
  cmake,
  pkg-config,
  pcsclite,
  udev,
  v4l-utils,
  nix-update-script,
  ...
}:
rustPlatform.buildRustPackage rec {
  pname = "recisdb";
  version = "1.3.2";

  src = fetchFromGitHub {
    owner = "kazuki0824";
    repo = "recisdb-rs";
    rev = version;
    fetchSubmodules = true;
    hash = "sha256-FMnr/sVvJQ5aQRX/DXqjmIAfA3Bd3U4cNUC0I/ahlmo=";
  };

  cargoHash = "sha256-VXktPRGidYOltoBajcwRQRxqnQ43E6qkfxZTQs+dBiU=";

  buildAndTestSubdir = "recisdb-rs";
  cargoBuildFeatures = [ "dvb" ];

  nativeBuildInputs = [
    cmake
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    pcsclite
    udev
    v4l-utils
  ];

  doCheck = false;

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--flake"
      "--version=stable"
    ];
  };

  meta = with lib; {
    description = "Rust-based ISDB tuner reader and ARIB STD-B25 decoder";
    homepage = "https://github.com/kazuki0824/recisdb-rs";
    license = licenses.gpl3Only;
    maintainers = [ ];
    mainProgram = "recisdb";
    platforms = platforms.linux;
  };
}
