{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  pkg-config,
  avisynthplus,
  nix-update-script,
  ...
}:
stdenv.mkDerivation {
  pname = "nnedi3";
  # 上流の cuda ブランチは AviSynthCUDAFilters のサブプロジェクト専用に
  # 作り替えられ、単体ではビルドできない。単体ビルド可能な avsp ブランチを追従する。
  version = "0.9.4.51-unstable-2026-09-20";

  src = fetchFromGitHub {
    owner = "rigaya";
    repo = "NNEDI3";
    rev = "a09c8e743ac42c7552bdf2514605e7e0253da0b6";
    hash = "sha256-MZFOMf5B7gPNGTZgtpTrBuHgk+OqHZhbVRCKwXrvtTc=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [ avisynthplus ];

  preConfigure = ''
    substituteInPlace nnedi3/meson.build \
      --replace-fail "install_dir : get_option('libdir')" "install_dir : 'lib/avisynth'"
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--flake"
      "--version=branch=avsp"
    ];
  };

  meta = with lib; {
    description = "NNEDI3 deinterlacing plugin for AviSynth+";
    homepage = "https://github.com/rigaya/NNEDI3";
    license = licenses.gpl2Plus;
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
  };
}
