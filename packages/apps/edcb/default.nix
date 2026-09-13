{
  lib,
  stdenv,
  fetchFromGitHub,
  edcb-material-webui,
  gnumake,
  glibc,
  openssl,
  lua5_2,
  libcap,
  libiconv,
  gnused,
  ...
}:
let
  materialWebUi = "${edcb-material-webui}/share/edcb-material-webui";
in
stdenv.mkDerivation rec {
  pname = "edcb";
  version = "0-unstable-2026-09-05";

  src = fetchFromGitHub {
    owner = "tkntrec";
    repo = "EDCB";
    rev = "84da43e95dcb905b9f641056ed489743de6dba4d";
    hash = "sha256-Lh0xs/c4rXadZA2Xp+2fSsZrlV6VWkcSa43QFjtsmvI=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    gnumake
    glibc.bin
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
    openssl
    lua5_2
    libcap
    libiconv
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

    cp -a "${materialWebUi}/HttpPublic/api" "$out/share/edcb/ini/HttpPublic/api"
    cp -a "${materialWebUi}/HttpPublic/E3" "$out/share/edcb/ini/HttpPublic/E3"

    # Upstream GetAppConfig() concatenates nil `zip` when [NVRAM] ZIP is unset,
    # aborting every GET /E3/ with a Lua "attempt to concatenate" error that
    # surfaces as HTTP 502 via reverse proxies. Guard against nil.
    chmod u+w "$out/share/edcb/ini/HttpPublic/E3/util.lua"
    substituteInPlace "$out/share/edcb/ini/HttpPublic/E3/util.lua" \
      --replace-fail '..zip..' '..(zip or "")..'

    install -m 0644 "${materialWebUi}/Setting/HttpPublic.ini" "$out/share/edcb/ini/Setting/HttpPublic.ini"
    install -m 0644 "${materialWebUi}/Setting/XCODE_OPTIONS.lua" "$out/share/edcb/ini/Setting/XCODE_OPTIONS.lua"

    ${glibc.bin}/bin/iconv -f CP932 -t UTF-8 ini/Bitrate.ini | tr -d '\r' > "$out/share/edcb/ini/Bitrate.ini"
    ${glibc.bin}/bin/iconv -f CP932 -t UTF-8 ini/BonCtrl.ini | tr -d '\r' | ${gnused}/bin/sed 's/\.dll$/.so/' > "$out/share/edcb/ini/BonCtrl.ini"
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
