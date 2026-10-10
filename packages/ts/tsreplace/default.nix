{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  pkg-config,
  ffmpeg,
  ...
}:
stdenv.mkDerivation rec {
  pname = "tsreplace";
  version = "0.22";

  src = fetchFromGitHub {
    owner = "rigaya";
    repo = "tsreplace";
    tag = version;
    hash = "sha256-41cRez194xFFOd0f1QN2NaGnNrPIPn3calzXQL8uGDU=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    ffmpeg
  ];

  postPatch = ''
    substituteInPlace meson.build \
      --replace-fail "version: run_command('bash', 'scripts/get-version.sh', check: true).stdout().strip()," "version: '${version}',"
  '';

  meta = with lib; {
    homepage = "https://github.com/rigaya/tsreplace";
    mainProgram = "tsreplace";
    changelog = "https://github.com/rigaya/tsreplace/releases/tag/${version}";
    description = "Tool to replace only video packets in MPEG-TS streams";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
