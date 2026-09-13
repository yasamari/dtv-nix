{
  lib,
  stdenvNoCC,
  python3,
  fetchFromGitHub,
  makeWrapper,
  ...
}:
stdenvNoCC.mkDerivation rec {
  pname = "danmaku2ass";
  version = "0-unstable-2024-08-28";

  src = fetchFromGitHub {
    owner = "m13253";
    repo = "danmaku2ass";
    rev = "ced881747670c2eb1c0dbd292c2a567f444b056a";
    hash = "sha256-yhfioN3/E46vFU1xT68OEM2OymBsB5XI+8WdotD745o=";
  };

  nativeBuildInputs = [ makeWrapper ];

  # Only the script itself is packaged (locale .mo files are not built,
  # matching historical behavior).
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm644 danmaku2ass.py "$out/share/danmaku2ass/danmaku2ass.py"
    makeWrapper "${python3}/bin/python3" "$out/bin/danmaku2ass" \
      --add-flags "$out/share/danmaku2ass/danmaku2ass.py"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Convert danmaku comments to ASS subtitles";
    homepage = "https://github.com/m13253/danmaku2ass";
    license = licenses.gpl3Only;
    maintainers = [ ];
    mainProgram = "danmaku2ass";
    platforms = platforms.linux;
  };
}
