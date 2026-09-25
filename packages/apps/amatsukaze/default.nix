{
  lib,
  stdenv,
  callPackage,
  makeWrapper,
  amatsukaze-server-cli,
  amatsukaze-script-command,
  amatsukaze-add-task,
  amatsukaze-native,
  amatsukaze-webui,
  danmaku2ass,
  ffmpeg_6,
  x264,
  x265,
  svt-av1,
  qsvenc,
  nvenc,
  gpac,
  mkvtoolnix,
  l-smash,
  tsreplace,
  tsreadex,
  psisiarc,
  b24tovtt,
  chapter_exe,
  join_logo_scp,
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
  nix-update-script,
  ...
}:
let
  common = callPackage ./common.nix { };
  inherit (common) version src dotnetRuntime;

  avisynthplusCuda = avisynthplus-cuda;
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
stdenv.mkDerivation {
  pname = "amatsukaze";
  inherit version src;

  strictDeps = true;
  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    exeDir="$out/lib/amatsukaze/exe_files"
    shareDir="$out/share/amatsukaze"

    mkdir -p "$out/bin" "$exeDir" "$shareDir"

    # Published outputs of the split dotnet builds. The three projects share
    # most files (bit-identical deterministic builds), so later copies
    # overwrite earlier ones. Copies preserve store modes (read-only), so
    # re-allow writes after each copy to keep merges working; the final tree
    # stays writable, as with the previous single-build layout.
    cp -a "${amatsukaze-server-cli}/lib/${amatsukaze-server-cli.pname}/." "$exeDir/"
    chmod -R u+w "$exeDir"
    cp -a "${amatsukaze-script-command}/lib/${amatsukaze-script-command.pname}/." "$exeDir/"
    chmod -R u+w "$exeDir"
    cp -a "${amatsukaze-add-task}/lib/${amatsukaze-add-task.pname}/." "$exeDir/"
    chmod -R u+w "$exeDir"

    # The WebUI is built as a separate package; the server expects its
    # static files at <apphost-dir>/wwwroot, so link them in.
    ln -s "${amatsukaze-webui}/share/amatsukaze-webui" "$exeDir/wwwroot"

    cp -a ${amatsukaze-native}/lib/libAmatsukaze.so "$exeDir/"
    cp -a ${amatsukaze-native}/bin/AmatsukazeCLI "$exeDir/"
    cp -a ${amatsukaze-native}/bin/AmatsukazeGenLogo "$exeDir/"

    cp -a defaults/. "$shareDir/"
    mkdir -p "$shareDir/scripts"
    cp -a scripts/. "$shareDir/scripts/"
    cp -a "${joinLogoScp}/share/join_logo_scp/JL" "$shareDir/JL"

    cp -a "${danmaku2ass}/share/danmaku2ass/danmaku2ass.py" "$shareDir/scripts/"
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

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--flake"
      "--version=stable"
      "--override-filename"
      "packages/apps/amatsukaze/common.nix"
    ];
  };

  meta = with lib; {
    description = "Linux build of Amatsukaze server and CLI tools";
    homepage = "https://github.com/rigaya/Amatsukaze";
    changelog = "https://github.com/rigaya/Amatsukaze/releases/tag/${version}";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "AmatsukazeServerCLI";
    platforms = [ "x86_64-linux" ];
  };
}
