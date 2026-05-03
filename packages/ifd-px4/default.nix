{
  pkgs,
  ...
}:
pkgs.stdenv.mkDerivation {
  pname = "ifd-px4";
  version = "develop-a86ff8f";

  src = pkgs.fetchFromGitHub {
    owner = "yyya-nico";
    repo = "px4_drv";
    rev = "a86ff8fcb151e7ccb76b0a73532632cbbd0cc27a";
    hash = "sha256-LrybxOi2+E7AQmSJYNBrI3XbiFNFSTeeId3Lw9LD0Eo=";
  };

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
      -I${pkgs.pcsclite.dev}/include \
      -I${pkgs.pcsclite.dev}/include/PCSC \
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

  meta = with pkgs.lib; {
    description = "PC/SC IFD handler for the px4_drv smart card reader";
    homepage = "https://github.com/yyya-nico/px4_drv/tree/develop/userland/ifd-px4";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
