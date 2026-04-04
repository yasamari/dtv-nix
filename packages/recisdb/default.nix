{ pkgs, ... }:
pkgs.rustPlatform.buildRustPackage rec {
  pname = "recisdb";
  version = "1.2.4";

  src = pkgs.fetchFromGitHub {
    owner = "kazuki0824";
    repo = "recisdb-rs";
    rev = version;
    fetchSubmodules = true;
    hash = "sha256-hjTMb2LWD7mN3ci83v+NxQW9wBdI9LnG6o2PmKlSakU=";
  };

  cargoHash = "sha256-c4yL5V1G9mU0vg9m9v9s6qji8jsIpHWtugO6tOPJm9Q=";

  buildAndTestSubdir = "recisdb-rs";
  cargoBuildFeatures = [ "dvb" ];

  nativeBuildInputs = [
    pkgs.cmake
    pkgs.pkg-config
    pkgs.rustPlatform.bindgenHook
  ];

  buildInputs = [
    pkgs.pcsclite
    pkgs.udev
    pkgs.v4l-utils
  ];

  doCheck = false;

  meta = with pkgs.lib; {
    description = "Rust-based ISDB tuner reader and ARIB STD-B25 decoder";
    homepage = "https://github.com/kazuki0824/recisdb-rs";
    license = licenses.gpl3Only;
    maintainers = [ ];
    mainProgram = "recisdb";
    platforms = platforms.linux;
  };
}
