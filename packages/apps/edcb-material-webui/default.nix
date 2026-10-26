{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
  ...
}:
stdenvNoCC.mkDerivation rec {
  pname = "edcb-material-webui";
  version = "0-unstable-2026-10-25";

  src = fetchFromGitHub {
    owner = "EMWUI";
    repo = "EDCB_Material_WebUI";
    rev = "628a3a89624834d1729b0932d23c7c5b97fd5d00";
    hash = "sha256-9CWWt7/4LtC6jyWOAoK9Xoe/x76s+Pf/g48foCgZ9iI=";
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
