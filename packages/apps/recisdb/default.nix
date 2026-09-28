{
  lib,
  rustPlatform,
  fetchFromGitHub,
  cmake,
  pkg-config,
  pcsclite,
  udev,
  v4l-utils,
  ...
}:
rustPlatform.buildRustPackage rec {
  pname = "recisdb";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "kazuki0824";
    repo = "recisdb-rs";
    rev = version;
    fetchSubmodules = true;
    hash = "sha256-xjUojKZXMtpQKMAPd96BfTp1Q3IJUtiuhGe6lca6Ai0=";
  };

  cargoHash = "sha256-8UAs1N44+3dVSdgHGGVl32+KMMVrur1j06yMpxxQz2s=";

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

  meta = with lib; {
    description = "Rust-based ISDB tuner reader and ARIB STD-B25 decoder";
    homepage = "https://github.com/kazuki0824/recisdb-rs";
    license = licenses.gpl3Only;
    maintainers = [ ];
    mainProgram = "recisdb";
    platforms = platforms.linux;
  };
}
