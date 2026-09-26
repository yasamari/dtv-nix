{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
  ...
}:
stdenvNoCC.mkDerivation rec {
  pname = "edcb-material-webui";
  version = "0-unstable-2026-09-22";

  src = fetchFromGitHub {
    owner = "EMWUI";
    repo = "EDCB_Material_WebUI";
    rev = "aa938f0ee5819bd00a65235316f19e463d14aa22";
    hash = "sha256-Evm4Pj+5BaoQ+hjECBAt2Ftr5+umThpN0dtxZqUoamY=";
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
