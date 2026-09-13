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

  sourceRoot = "source/userland/ifd-px4";

  strictDeps = true;
  dontConfigure = true;

  buildPhase = ''
    runHook preBuild

    $CC \
      -Wall \
      -O2 \
      -fPIC \
      -I../../include \
      -I${pcsclite.dev}/include \
      -I${pcsclite.dev}/include/PCSC \
      -c ifdhandler.c

    $CC -shared -o libpx4ifd.so ifdhandler.o

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -D -m 755 libpx4ifd.so "$out/pcsc/drivers/ifd-px4.bundle/Contents/Linux/libpx4ifd.so"
    install -D -m 644 Info.plist "$out/pcsc/drivers/ifd-px4.bundle/Contents/Info.plist"

    runHook postInstall
  '';

  meta = with lib; {
    description = "PC/SC IFD handler for the px4_drv smart card reader";
    homepage = "https://github.com/yyya-nico/px4_drv/tree/develop/userland/ifd-px4";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
