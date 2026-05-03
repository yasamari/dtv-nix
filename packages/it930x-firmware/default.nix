{
  pkgs,
  ...
}:
pkgs.stdenv.mkDerivation {
  pname = "it930x-firmware";
  version = "1";

  src = pkgs.fetchFromGitHub {
    owner = "tsukumijima";
    repo = "px4_drv";
    rev = "v0.5.6";
    hash = "sha256-E/hGh2F6xsNHJlf6P5RjfT7vCYtpZC/6opiPqMVEsNk=";
  };
  plexSrc = pkgs.fetchzip {
    url = "http://plex-net.co.jp/plex/pxw3u4/pxw3u4_BDA_ver1x64.zip";
    sha256 = "1ky28m8hv86vivk2clps5qpmlrmlvfya8qcfmcvpd3n2kisbqsrl";
  };

  sourceRoot = "source/fwtool";

  postBuild = ''
    ./fwtool $plexSrc/PXW3U4.sys it930x-firmware.bin
  '';

  installPhase = ''
    install -D -m 644 it930x-firmware.bin "$out/lib/firmware/it930x-firmware.bin"
  '';

  meta = with pkgs.lib; {
    description = "it930x-firmware for px4_drv";
    homepage = "https://github.com/tsukumijima/px4_drv";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
