{
  pkgs,
  perSystem,
  useLegacyQsvenc ? false,
  ...
}:
let
  common = import ./common.nix { inherit pkgs perSystem; };
  ffmpeg = pkgs.ffmpeg_6;
  avisynthplusCuda = perSystem.self.avisynthplus-cuda;
  native = import ./native.nix {
    inherit
      pkgs
      common
      ffmpeg
      avisynthplusCuda
      ;
  };

  inherit (common)
    version
    src
    dotnetSdk
    dotnetRuntime
    dotnetVersionPatch
    ;

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
    pkgs.ffmpeg_6
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

  runtimePath = pkgs.lib.makeBinPath ([ dotnetRuntime ] ++ runtimeTools);
  cudaDriverLibraryPath = "/run/opengl-driver/lib:/run/opengl-driver-32/lib";
in
pkgs.buildDotnetModule {
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

    mkdir -p "$exeDir/plugins64"
    cp -a defaults/exe_files/plugins64/. "$exeDir/plugins64/"

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

  meta = with pkgs.lib; {
    description = "Linux build of Amatsukaze server and CLI tools";
    homepage = "https://github.com/rigaya/Amatsukaze";
    changelog = "https://github.com/rigaya/Amatsukaze/releases/tag/${version}";
    license = licenses.mit;
    mainProgram = "AmatsukazeServerCLI";
    platforms = [ "x86_64-linux" ];
  };
}
