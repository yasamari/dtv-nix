{
  lib,
  stdenv,
  callPackage,
  linuxPackages,
  kernel ? linuxPackages.kernel,
  ...
}:
let
  inherit (callPackage ./source.nix { }) version px4DrvSrc;
in
stdenv.mkDerivation {
  pname = "px4_drv";
  inherit version;

  src = px4DrvSrc;

  sourceRoot = "source/driver";

  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail \
      $'\t$(cmd_prefix)rev=`git rev-list --count HEAD` 2>/dev/null; \\\n\trev_name=`git name-rev --name-only HEAD` 2>/dev/null; \\\n\tcommit=`git rev-list --max-count=1 HEAD` 2>/dev/null; \\' \
      $'\t$(cmd_prefix)if command -v git >/dev/null 2>&1; then \\\n\trev=`git rev-list --count HEAD` 2>/dev/null; \\\n\trev_name=`git name-rev --name-only HEAD` 2>/dev/null; \\\n\tcommit=`git rev-list --max-count=1 HEAD` 2>/dev/null; \\\n\telse \\\n\trev=; \\\n\trev_name=; \\\n\tcommit=; \\\n\tfi; \\'
  '';

  hardeningDisable = [
    "pic"
  ];

  makeFlags = [
    "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  installPhase = ''
    runHook preInstall

    install -D -m 644 px4_drv.ko "$out/lib/modules/${kernel.modDirVersion}/misc/px4_drv.ko"
    install -D -m 644 ../etc/99-px4video.rules "$out/lib/udev/rules.d/99-px4video.rules"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Unofficial Linux driver for PLEX PX4/PX5/PX-MLT series ISDB-T/S receivers";
    homepage = "https://github.com/yyya-nico/px4_drv";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
