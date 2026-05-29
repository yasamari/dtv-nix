{
  pkgs,
  perSystem,
  useLegacyQsvenc ? false,
}:
let
  lib = pkgs.lib;

  version = "1.0.7.2";

  src = pkgs.fetchFromGitHub {
    owner = "rigaya";
    repo = "Amatsukaze";
    tag = version;
    hash = "sha256-8rQaHc8bHLPnQ0rzEe2nP14UYXWw15jaLYGlgOZpk2E=";
    fetchSubmodules = true;
  };

  dotnetSdk = pkgs.dotnetCorePackages.sdk_10_0;
  dotnetRuntime = pkgs.dotnetCorePackages.aspnetcore_10_0;

  dotnetNugetDeps = pkgs.dotnetCorePackages.mkNugetDeps {
    name = "amatsukaze";
    sourceFile = ./deps.json;
  };

  ffmpeg = pkgs.ffmpeg_6;

  avisynthplusCuda = perSystem.self.avisynthplus-cuda;
  avisynthcudafilters = perSystem.self.avisynthcudafilters;
  nnedi3 = perSystem.self.nnedi3;
  masktools = perSystem.self.masktools;
  mvtools = perSystem.self.mvtools;
  rgtools = perSystem.self.rgtools;
  yadifmod2 = perSystem.self.yadifmod2;
  tivtc = perSystem.self.tivtc;

  qsvenc = if useLegacyQsvenc then perSystem.self."qsvenc-legacy" else perSystem.self.qsvenc;
  nvenc = perSystem.self.nvenc;
  tsreplace = perSystem.self.tsreplace;
  tsreadex = perSystem.self.tsreadex;
  psisiarc = perSystem.self.psisiarc;
  b24tovtt = perSystem.self.b24tovtt;
  chapterExe = perSystem.self.chapter_exe;
  joinLogoScp = perSystem.self.join_logo_scp;
  amatsukazeAddTask = perSystem.self.amatsukaze-add-task;

  runtimeTools = [
    ffmpeg
    pkgs.x264
    pkgs.x265
    pkgs.svt-av1
    qsvenc
    nvenc
    pkgs.gpac
    pkgs.mkvtoolnix
    pkgs."l-smash"
    tsreplace
    tsreadex
    psisiarc
    b24tovtt
    chapterExe
    joinLogoScp
    amatsukazeAddTask
    pkgs.fdk-aac-encoder
    pkgs.opus-tools
    pkgs.whisper-cpp
  ];

  runtimePath = lib.makeBinPath ([ dotnetRuntime ] ++ runtimeTools);
  cudaDriverLibraryPath = "/run/opengl-driver/lib:/run/opengl-driver-32/lib";

  mesonVersionPatch = ''
    substituteInPlace meson.build \
      --replace-fail 'version_full=$(git describe --tags) && \' 'version_full="${version}" && \' \
      --replace-fail 'version_short=$(git describe --abbrev=0 --tags) && \' 'version_short="${version}" && \'
  '';

  dotnetVersionPatch = ''
    substituteInPlace AmatsukazeServer/Version.sh \
      --replace-fail '/bin/bash' '${pkgs.bash}/bin/bash' \
      --replace-fail 'VER=$(git describe --tags)' 'VER="${version}"'
    substituteInPlace AmatsukazeServer/Properties/AssemblyInfo.tt \
      --replace-fail 'AssemblyVersion("0.0.0.0")' 'AssemblyVersion("@SHORTVERSION@")'
    (cd AmatsukazeServer && ./Version.sh)
  '';
in
{
  inherit
    version
    src
    dotnetSdk
    dotnetRuntime
    dotnetNugetDeps
    ffmpeg
    avisynthplusCuda
    avisynthcudafilters
    nnedi3
    masktools
    mvtools
    rgtools
    yadifmod2
    tivtc
    qsvenc
    nvenc
    tsreplace
    tsreadex
    psisiarc
    b24tovtt
    chapterExe
    joinLogoScp
    amatsukazeAddTask
    runtimeTools
    runtimePath
    cudaDriverLibraryPath
    mesonVersionPatch
    dotnetVersionPatch
    ;
}
