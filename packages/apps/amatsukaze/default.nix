{
  lib,
  callPackage,
  buildDotnetModule,
  ffmpeg_6,
  x264,
  x265,
  svt-av1,
  gpac,
  mkvtoolnix,
  l-smash,
  fdk-aac-encoder,
  opus-tools,
  whisper-cpp,
  python3,
  avisynthplus-cuda,
  avisynthcudafilters,
  nnedi3,
  masktools,
  mvtools,
  rgtools,
  yadifmod2,
  tivtc,
  qsvenc,
  nvenc,
  tsreplace,
  tsreadex,
  psisiarc,
  b24tovtt,
  chapter_exe,
  join_logo_scp,
  amatsukaze-add-task,
  ...
}:
let
  common = callPackage ./common.nix { };
  ffmpeg = ffmpeg_6;
  avisynthplusCuda = avisynthplus-cuda;
  native = callPackage ./native.nix {
    inherit
      common
      ffmpeg
      avisynthplusCuda
      ;
  };

  inherit (common)
    version
    src
    danmaku2ass
    dotnetSdk
    dotnetRuntime
    dotnetVersionPatch
    ;

  chapterExe = chapter_exe;
  joinLogoScp = join_logo_scp;
  amatsukazeAddTask = amatsukaze-add-task;

  runtimeTools = [
    ffmpeg_6
    x264
    x265
    svt-av1
    qsvenc
    nvenc
    gpac
    mkvtoolnix
    l-smash
    tsreplace
    tsreadex
    psisiarc
    b24tovtt
    chapterExe
    joinLogoScp
    amatsukazeAddTask
    fdk-aac-encoder
    opus-tools
    whisper-cpp
    python3
  ];

  runtimePath = lib.makeBinPath ([ dotnetRuntime ] ++ runtimeTools);
  cudaDriverLibraryPath = "/run/opengl-driver/lib:/run/opengl-driver-32/lib";
in
buildDotnetModule {
  pname = "amatsukaze";
  inherit version src;

  projectFile = [
    "AmatsukazeServer/AmatsukazeServer.csproj"
    "AmatsukazeServerCLI/AmatsukazeServerCLI.csproj"
    "ScriptCommand/ScriptCommand.csproj"
    "AmatsukazeAddTask/AmatsukazeAddTask.csproj"
  ];
  nugetDeps = ./deps.json;

  dotnet-sdk = dotnetSdk;
  dotnet-runtime = dotnetRuntime;

  enableParallelBuilding = false;

  selfContainedBuild = false;

  dontDotnetFixup = true;

  postPatch = dotnetVersionPatch + ''
    substituteInPlace AmatsukazeServer/Server/EncodeServer.cs \
      --replace-fail 'setting.AmatsukazePath = Path.Combine(basePath, "AmatsukazeCLI" + exeDefaultAppendix);' 'setting.AmatsukazePath = "AmatsukazeCLI";'
    substituteInPlace AmatsukazeServer/Server/EncodeServer.cs \
      --replace-fail 'setting.NicoConvASSPath = Path.Combine(basePath, "nicojk_ass.py");' 'setting.NicoConvASSPath = "nicojk_ass.py";'
  '';

  dotnetBuildFlags = [
    "-p:ContinuousIntegrationBuild=true"
    "-p:Deterministic=true"
  ];

  postInstall = ''
    exeDir="$out/lib/amatsukaze/exe_files"
    shareDir="$out/share/amatsukaze"

    mkdir -p "$out/bin" "$exeDir" "$shareDir"

    shopt -s dotglob
    for f in "$out/lib/amatsukaze"/*; do
      [[ "$f" != "$exeDir" ]] && mv "$f" "$exeDir/"
    done
    shopt -u dotglob

    cp -a ${native}/lib/libAmatsukaze.so "$exeDir/"
    cp -a ${native}/bin/AmatsukazeCLI "$exeDir/"
    cp -a ${native}/bin/AmatsukazeGenLogo "$exeDir/"

    cp -a defaults/. "$shareDir/"
    mkdir -p "$shareDir/scripts"
    cp -a scripts/. "$shareDir/scripts/"
    cp -a "${joinLogoScp}/share/join_logo_scp/JL" "$shareDir/JL"

    cp -a "${danmaku2ass}/danmaku2ass.py" "$shareDir/scripts/"
    chmod +x "$shareDir/scripts/nicojk_ass.py" "$shareDir/scripts/danmaku2ass.py"
    ln -s "$shareDir/scripts/nicojk_ass.py" "$out/bin/nicojk_ass.py"
    ln -s "$shareDir/scripts/danmaku2ass.py" "$out/bin/danmaku2ass.py"

    mkdir -p "$exeDir/plugins64"
    cp -a defaults/exe_files/plugins64/. "$exeDir/plugins64/"
    cp -a defaults/exe_files/ch_sid.txt "$exeDir/"

    shopt -s nullglob
    for pluginPath in \
      "${avisynthplusCuda}/lib/avisynth" \
      "${avisynthcudafilters}/lib/avisynth" \
      "${nnedi3}/lib/avisynth" \
      "${masktools}/lib/avisynth" \
      "${mvtools}/lib/avisynth" \
      "${rgtools}/lib/avisynth" \
      "${yadifmod2}/lib/avisynth" \
      "${tivtc}/lib/avisynth"; do
      if [ -d "$pluginPath" ]; then
        for plugin in "$pluginPath"/*.so*; do
          ln -sf "$plugin" "$exeDir/plugins64/"
        done
      fi
    done

    ln -sf "${masktools}/lib/avisynth/libmasktools2.so" "$exeDir/plugins64/mt_masktools.so"

    # Wrappers
    makeWrapper "$exeDir/AmatsukazeCLI" "$out/bin/AmatsukazeCLI" \
      --prefix LD_LIBRARY_PATH : "${cudaDriverLibraryPath}" \
      --prefix PATH : "${runtimePath}"

    makeWrapper "$exeDir/AmatsukazeGenLogo" "$out/bin/AmatsukazeGenLogo" \
      --prefix LD_LIBRARY_PATH : "${cudaDriverLibraryPath}"

    makeWrapper "$exeDir/AmatsukazeServerCLI" "$out/bin/AmatsukazeServerCLI" \
      --prefix LD_LIBRARY_PATH : "${cudaDriverLibraryPath}" \
      --prefix PATH : "$out/bin:${runtimePath}" \
      --set DOTNET_ROOT "${dotnetRuntime}/share/dotnet"

    makeWrapper "$exeDir/ScriptCommand" "$out/bin/ScriptCommand" \
      --set DOTNET_ROOT "${dotnetRuntime}/share/dotnet"

    makeWrapper "$exeDir/AmatsukazeAddTask" "$out/bin/AmatsukazeAddTask" \
      --set DOTNET_ROOT "${dotnetRuntime}/share/dotnet"

    ln -s "$exeDir/libAmatsukaze.so" "$out/lib/libAmatsukaze.so"
  '';

  meta = with lib; {
    description = "Linux build of Amatsukaze server and CLI tools";
    homepage = "https://github.com/rigaya/Amatsukaze";
    changelog = "https://github.com/rigaya/Amatsukaze/releases/tag/${version}";
    license = licenses.mit;
    mainProgram = "AmatsukazeServerCLI";
    platforms = [ "x86_64-linux" ];
  };
}
