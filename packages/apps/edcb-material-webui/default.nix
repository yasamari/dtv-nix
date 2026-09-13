{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation rec {
  pname = "edcb-material-webui";
  version = "0-unstable-2026-09-11";

  src = fetchFromGitHub {
    owner = "EMWUI";
    repo = "EDCB_Material_WebUI";
    rev = "9e4ca29ac9f6c8ce05574e8e25ed4dd436625a1c";
    hash = "sha256-pakYstzImCpX/lMeT+Zg1/K+hJfli9rabxtPq5XSiJk=";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/edcb-material-webui"
    cp -a HttpPublic Setting "$out/share/edcb-material-webui/"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Material Design WebUI for EDCB";
    homepage = "https://github.com/EMWUI/EDCB_Material_WebUI";
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
