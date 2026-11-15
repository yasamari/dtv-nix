{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fftwFloat,
  nix-update-script,
  ...
}:
stdenv.mkDerivation rec {
  pname = "mvtools";
  version = "2.7.49";

  src = fetchFromGitHub {
    owner = "pinterf";
    repo = "mvtools";
    tag = version;
    hash = "sha256-5qsLD42OpfLt/sX/ZUsRsBECn2omaA3YqB+fqlB/8ug=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ fftwFloat ];

  cmakeFlags = [
    "-DCMAKE_INSTALL_LIBDIR=lib"
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--flake"
      "--version=stable"
    ];
  };

  meta = with lib; {
    description = "MVTools, DePan, and DePanEstimate Avisynth plugins";
    homepage = "https://github.com/pinterf/mvtools";
    license = licenses.gpl2Plus;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
