{
  lib,
  stdenv,
  callPackage,
  ...
}:
let
  inherit (callPackage ../px4_drv/source.nix { }) version px4DrvSrc;
in
stdenv.mkDerivation {
  pname = "it930x-firmware";
  inherit version;

  src = px4DrvSrc;

  dontBuild = true;

  installPhase = ''
    install -D -m 644 etc/it930x-firmware.bin "$out/lib/firmware/it930x-firmware.bin"
  '';

  meta = with lib; {
    description = "it930x-firmware for px4_drv";
    homepage = "https://github.com/tsukumijima/px4_drv";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
