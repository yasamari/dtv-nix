{
  lib,
  stdenv,
  callPackage,
  fetchzip,
  ...
}:
let
  inherit (callPackage ../px4_drv/source.nix { }) px4DrvSrc;
in
stdenv.mkDerivation {
  pname = "it930x-firmware";
  version = "1";

  src = px4DrvSrc;
  plexSrc = fetchzip {
    url = "http://plex-net.co.jp/plex/pxw3u4/pxw3u4_BDA_ver1x64.zip";
    hash = "sha256-NGu8dJzCjnY3q45hpLzbtGZaLy76UibmjtugDVFFws8=";
  };

  sourceRoot = "source/fwtool";

  postBuild = ''
    ./fwtool $plexSrc/PXW3U4.sys it930x-firmware.bin
  '';

  installPhase = ''
    install -D -m 644 it930x-firmware.bin "$out/lib/firmware/it930x-firmware.bin"
  '';

  meta = with lib; {
    description = "it930x-firmware for px4_drv";
    homepage = "https://github.com/yyya-nico/px4_drv";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
