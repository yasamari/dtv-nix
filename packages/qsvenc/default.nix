# https://github.com/spotdemo4/nur/blob/main/packages/qsvenc/default.nix

# MIT License
#
# Copyright (c) 2025 Trev
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
{
  pkgs,
  useLegacyIntel ? false,
}:
let
  intelMediaRuntime = if useLegacyIntel then pkgs.intel-media-sdk else pkgs.vpl-gpu-rt;

  intelComputeRuntime =
    if useLegacyIntel then pkgs.intel-compute-runtime-legacy1 else pkgs.intel-compute-runtime;
in
pkgs.stdenv.mkDerivation rec {
  pname = "qsvenc";
  version = "8.14";

  hardeningDisable = [ "all" ];

  src = pkgs.fetchFromGitHub {
    owner = "rigaya";
    repo = "QSVEnc";
    tag = version;
    hash = "sha256-+jcWeuZQMo0rpJFvX3S8hDrPuhMQM0f7YvC3FCYODLU=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = with pkgs; [
    cargo
    cmake
    git
    makeWrapper
    meson
    pkg-config
    cargo-c
    ninja
  ];

  buildInputs = with pkgs; [
    # libs
    libva
    libdrm
    ffmpeg
    libass
    libvpl
    opencl-headers
    ocl-icd
    libx11
    libdovi
    hdr10plus

    # intel
    intel-media-driver
    intelMediaRuntime
    intelComputeRuntime
    cmrt
  ];

  postPatch = ''
    substituteInPlace meson.build \
      --replace-fail \
        "version: run_command('git', 'describe', '--tags', '--abbrev=0', check: true).stdout().strip()," \
        "version: '${version}',"
  '';

  configurePhase = ''
    runHook preConfigure

    meson setup build \
      --buildtype release \
      --prefix "$out" \
      -Dopencl_headers=${pkgs.opencl-headers}/include \
      -Denable_avisynth=false \
      -Denable_vapoursynth=false

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    meson compile -C build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    meson install -C build

    wrapProgram $out/bin/qsvencc \
      --prefix LD_LIBRARY_PATH : "${
        pkgs.lib.makeLibraryPath [
          pkgs.intel-media-driver
          intelMediaRuntime
          intelComputeRuntime
          pkgs.libva
          pkgs.libdrm
          pkgs.ocl-icd
        ]
      }" \
      --set LIBVA_DRIVER_NAME iHD \
      --prefix LIBVA_DRIVERS_PATH : "${pkgs.intel-media-driver}/lib/dri" \
      --prefix OCL_ICD_VENDORS : "${intelComputeRuntime}/etc/OpenCL/vendors"

    runHook postInstall
  '';

  meta = with pkgs.lib; {
    homepage = "https://github.com/rigaya/QSVEnc";
    mainProgram = "qsvencc";
    changelog = "https://github.com/rigaya/QSVEnc/releases/tag/${src.tag}";
    description = "QSV high-speed encoding performance experiment tool";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
  };
}
