{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
  ...
}:
stdenvNoCC.mkDerivation rec {
  pname = "edcb-material-webui";
  version = "0-unstable-2026-11-13";

  src = fetchFromGitHub {
    owner = "EMWUI";
    repo = "EDCB_Material_WebUI";
    rev = "07e46c849f3d689ce4758e18a31f734334d5a90b";
    hash = "sha256-iu2NWDXGN+bBI6TKeE7EhipIjd3amksJxMnQ4AGy4IM=";
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
