{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
  ...
}:
stdenvNoCC.mkDerivation rec {
  pname = "edcb-material-webui";
  version = "0-unstable-2026-10-08";

  src = fetchFromGitHub {
    owner = "EMWUI";
    repo = "EDCB_Material_WebUI";
    rev = "0eb88e3a38b4ba2bfb2df0accab66dc08daa0b6d";
    hash = "sha256-W88pW5ikD2PF9rf/JvMuFJeh5QrCFf6h/gdBIl6tjwk=";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/edcb-material-webui"
    cp -a HttpPublic Setting "$out/share/edcb-material-webui/"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--flake"
      "--version=branch=E3"
    ];
  };

  meta = with lib; {
    description = "Material Design WebUI for EDCB";
    homepage = "https://github.com/EMWUI/EDCB_Material_WebUI";
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
