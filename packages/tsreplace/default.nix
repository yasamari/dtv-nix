{ pkgs, ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "tsreplace";
  version = "0.19";

  src = pkgs.fetchFromGitHub {
    owner = "rigaya";
    repo = "tsreplace";
    tag = version;
    hash = "sha256-LIz237ngKpLVWkHtOv+V5i5xIi3Y1v1NLG4T52qO0aA=";
  };

  nativeBuildInputs = with pkgs; [
    meson
    ninja
    pkg-config
  ];

  buildInputs = with pkgs; [
    ffmpeg
  ];

  postPatch = ''
    substituteInPlace meson.build \
      --replace-fail "version: run_command('git', 'describe', '--tags', '--abbrev=0', check: true).stdout().strip()," "version: '${version}',"

    substituteInPlace app/rgy_log.cpp \
      --replace-fail "ret = _ftprintf(stderr, mes);" "ret = _ftprintf(stderr, _T(\"%s\"), mes);"
  '';

  meta = with pkgs.lib; {
    homepage = "https://github.com/rigaya/tsreplace";
    mainProgram = "tsreplace";
    changelog = "https://github.com/rigaya/tsreplace/releases/tag/${version}";
    description = "Tool to replace only video packets in MPEG-TS streams";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
