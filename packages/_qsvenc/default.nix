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
  pkgs ? null,
  lib ? pkgs.lib,
  stdenv ? pkgs.stdenv,
  fetchFromGitHub ? pkgs.fetchFromGitHub,
  cmake ? pkgs.cmake,
  pkg-config ? pkgs.pkg-config,
  cargo-c ? pkgs.cargo-c,
  git ? pkgs.git,
  wget ? pkgs.wget,
  makeWrapper ? pkgs.makeWrapper,
  libva ? pkgs.libva,
  libdrm ? pkgs.libdrm,
  ffmpeg ? pkgs.ffmpeg,
  libass ? pkgs.libass,
  libvpl ? pkgs.libvpl,
  opencl-headers ? pkgs.opencl-headers,
  ocl-icd ? pkgs.ocl-icd,
  libdovi ? pkgs.libdovi,
  cargo ? pkgs.cargo,
  hdr10plus ? pkgs.hdr10plus,
  intel-media-driver ? pkgs.intel-media-driver,
  intel-media-sdk ? pkgs.intel-media-sdk,
  intel-compute-runtime-legacy1 ? pkgs.intel-compute-runtime-legacy1,
  intel-compute-runtime ? pkgs.intel-compute-runtime,
  vpl-gpu-rt ? pkgs.vpl-gpu-rt,
  cmrt ? pkgs.cmrt,
  useLegacyIntel ? false,
}:
let
  intelMediaRuntime = if useLegacyIntel then intel-media-sdk else vpl-gpu-rt;

  intelComputeRuntime =
    if useLegacyIntel then intel-compute-runtime-legacy1 else intel-compute-runtime;
in
stdenv.mkDerivation rec {
  pname = "qsvenc";
  version = "8.04";

  hardeningDisable = [ "all" ];

  src = fetchFromGitHub {
    owner = "rigaya";
    repo = "QSVEnc";
    tag = version;
    hash = "sha256-stqAmOQEdPhfp9PFoFXoSdARb1BekkEu71NLzJ/Ujj4=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    cargo-c
    git
    wget
    makeWrapper
  ];

  buildInputs = [
    # libs
    libva
    libdrm
    ffmpeg
    libass
    libvpl
    opencl-headers
    ocl-icd
    libdovi
    cargo
    hdr10plus

    # intel
    intel-media-driver
    intelMediaRuntime
    intelComputeRuntime
    cmrt
  ];

  postPatch = ''
    substituteInPlace QSVPipeline/rgy_opencl.cpp \
      --replace 'img_desc.mem_object' 'img_desc.buffer'
  '';

  configurePhase = ''
    runHook preConfigure

    patchShebangs ./configure

    export LD="$CXX"

    ./configure

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    make

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -v qsvencc $out/bin/

    wrapProgram $out/bin/qsvencc \
      --prefix LD_LIBRARY_PATH : "${
        lib.makeLibraryPath [
          intel-media-driver
          intelMediaRuntime
          intelComputeRuntime
          libva
          libdrm
          ocl-icd
        ]
      }" \
      --set LIBVA_DRIVER_NAME iHD \
      --prefix LIBVA_DRIVERS_PATH : "${intel-media-driver}/lib/dri" \
      --prefix OCL_ICD_VENDORS : "${intelComputeRuntime}/etc/OpenCL/vendors"

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/rigaya/QSVEnc";
    mainProgram = "qsvencc";
    changelog = "https://github.com/rigaya/QSVEnc/releases/tag/${src.tag}";
    description = "QSV high-speed encoding performance experiment tool";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
  };
}
