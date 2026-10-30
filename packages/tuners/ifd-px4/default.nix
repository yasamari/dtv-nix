{
  lib,
  stdenv,
  callPackage,
  pcsclite,
  ...
}:
let
  inherit (callPackage ../px4_drv/source.nix { }) version px4DrvSrc;
in
stdenv.mkDerivation {
  pname = "ifd-px4";
  inherit version;

  src = px4DrvSrc;

  sourceRoot = "source/pcsc";

  strictDeps = true;
  dontConfigure = true;

  makeFlags = [
    "BUILD=build"
    "DESTDIR=${placeholder "out"}"
    "USBDROPDIR=/pcsc/drivers"
    "PCSC_CFLAGS=-I${pcsclite.dev}/include/PCSC"
  ];

  meta = with lib; {
    description = "PC/SC IFD handler for the px4_drv smart card reader";
    homepage = "https://github.com/tsukumijima/px4_drv/tree/v${version}/pcsc";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
