{ pkgs, ... }:
let
  lib = pkgs.lib;

  materialWebUiSrc = pkgs.fetchFromGitHub {
    owner = "EMWUI";
    repo = "EDCB_Material_WebUI";
    rev = "3ef980f389b42a3b22d190a8c5d96cebd2017203";
    hash = "sha256-8uRquZSu0UcJ8tIR/HKu1yb/MAdaCcuiguqYrxkY5h0=";
  };
in
pkgs.stdenv.mkDerivation rec {
  pname = "edcb";
  version = "work-plus-s-240212";

  src = pkgs.fetchFromGitHub {
    owner = "tkntrec";
    repo = "EDCB";
    rev = "2218c9789a1ee8355bd11b3d7eddb55888756c5e";
    hash = "sha256-PSiEaleQWnUX1ateGRablROj37Q02NenRo8dvxJH/Pw=";
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
    cp -a "${materialWebUiSrc}/HttpPublic/EMWUI" "$out/share/edcb/ini/HttpPublic/EMWUI"

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
