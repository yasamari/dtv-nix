{ pkgs, ... }:
let
  lib = pkgs.lib;

  materialWebUiSrc = pkgs.fetchFromGitHub {
    owner = "EMWUI";
    repo = "EDCB_Material_WebUI";
    rev = "1104c0e34d0d96d8516204219d3ce4f85e3e9618";
    hash = "sha256-RSSQGvqm8R1PkvEhi1hCB44Qj3K/Rwg9J8iiH7pNF1g=";
  };
in
pkgs.stdenv.mkDerivation rec {
  pname = "edcb";
  version = "0-unstable-2026-07-03";

  src = pkgs.fetchFromGitHub {
    owner = "tkntrec";
    repo = "EDCB";
    rev = "529e92e8f927fd22086152ce2b19c4808be990fe";
    hash = "sha256-MWY1ds6G30AMXFR0KwfjkfxZ/XjbMIYFhTP7j1KDfYc=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    pkgs.gnumake
    pkgs.glibc.bin
  ];

  postPatch = ''
    substituteInPlace Common/PathUtil.h \
      --replace-fail 'define EDCB_INI_ROOT L"/var/local/edcb"' 'define EDCB_INI_ROOT L"/var/lib/edcb"' \
      --replace-fail 'define EDCB_LIB_ROOT L"/usr/local/lib/edcb"' 'define EDCB_LIB_ROOT L"/var/lib/edcb/lib"'

    substituteInPlace EpgTimerSrv/EpgTimerSrv/Makefile \
      --replace-fail '-llua5.2' '-llua'

    substituteInPlace ini/HttpPublic/legacy/util.lua \
      --replace-fail 'ALLOW_SETTING=false' 'ALLOW_SETTING=true'
  '';

  buildInputs = [
    pkgs.openssl
    pkgs.lua5_2
    pkgs.libcap
    pkgs.libiconv
  ];

  buildPhase = ''
    runHook preBuild

    make -C Document/Unix

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin" "$out/lib/edcb" "$out/share/edcb/ini/Setting"

    install -m 0755 EpgDataCap_Bon/EpgDataCap_Bon/EpgDataCap_Bon "$out/bin/EpgDataCap_Bon"
    install -m 0755 EpgTimerSrv/EpgTimerSrv/EpgTimerSrv "$out/bin/EpgTimerSrv"

    install -m 0644 EpgDataCap3/EpgDataCap3/EpgDataCap3.so "$out/lib/edcb/EpgDataCap3.so"
    install -m 0644 SendTSTCP/SendTSTCP/SendTSTCP.so "$out/lib/edcb/SendTSTCP.so"
    install -m 0644 Write_Default/Write_Default/Write_Default.so "$out/lib/edcb/Write_Default.so"
    install -m 0644 RecName_Macro/RecName_Macro/RecName_Macro.so "$out/lib/edcb/RecName_Macro.so"

    cp -a ini/HttpPublic "$out/share/edcb/ini/HttpPublic"

    cp -a "${materialWebUiSrc}/HttpPublic/api" "$out/share/edcb/ini/HttpPublic/api"
    cp -a "${materialWebUiSrc}/HttpPublic/E3" "$out/share/edcb/ini/HttpPublic/E3"

    install -m 0644 "${materialWebUiSrc}/Setting/HttpPublic.ini" "$out/share/edcb/ini/Setting/HttpPublic.ini"
    install -m 0644 "${materialWebUiSrc}/Setting/XCODE_OPTIONS.lua" "$out/share/edcb/ini/Setting/XCODE_OPTIONS.lua"

    ${pkgs.glibc.bin}/bin/iconv -f CP932 -t UTF-8 ini/Bitrate.ini | tr -d '\r' > "$out/share/edcb/ini/Bitrate.ini"
    ${pkgs.glibc.bin}/bin/iconv -f CP932 -t UTF-8 ini/BonCtrl.ini | tr -d '\r' | ${pkgs.gnused}/bin/sed 's/\.dll$/.so/' > "$out/share/edcb/ini/BonCtrl.ini"
    tr -d '\r' < ini/ContentTypeText.txt > "$out/share/edcb/ini/ContentTypeText.txt"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Linux build of EDCB (EpgTimerSrv + plugins)";
    homepage = "https://github.com/tkntrec/EDCB";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "EpgTimerSrv";
    platforms = platforms.linux;
  };
}
