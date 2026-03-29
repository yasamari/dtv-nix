{ pkgs, ... }:
let
  lib = pkgs.lib;

  ffmpeg = if pkgs ? ffmpeg_6 then pkgs.ffmpeg_6 else pkgs.ffmpeg;
  dotnetSdk = pkgs.dotnetCorePackages.sdk_10_0;
  dotnetRuntime = pkgs.dotnetCorePackages.aspnetcore_10_0;

  dotnetNugetDeps = pkgs.dotnetCorePackages.mkNugetDeps {
    name = "amatsukaze";
    sourceFile = ./deps.json;
  };

  avisynthplusCuda = pkgs.callPackage ../avisynthplus-cuda { };
  avisynthcudafilters = pkgs.callPackage ../avisynthcudafilters { };
  nnedi3 = pkgs.callPackage ../nnedi3 { };
  masktools = pkgs.callPackage ../masktools { };
  mvtools = pkgs.callPackage ../mvtools { };
  rgtools = pkgs.callPackage ../rgtools { };
  yadifmod2 = pkgs.callPackage ../yadifmod2 { };
  tivtc = pkgs.callPackage ../tivtc { };

  qsvenc = pkgs.callPackage ../qsvenc { };
  nvenc = pkgs.callPackage ../nvenc { };
  tsreplace = pkgs.callPackage ../tsreplace { };
  tsreadex = pkgs.callPackage ../tsreadex { };
  psisiarc = pkgs.callPackage ../psisiarc { };
  b24tovtt = pkgs.callPackage ../b24tovtt { };
  chapterExe = pkgs.callPackage ../chapter_exe { };
  joinLogoScp = pkgs.callPackage ../join_logo_scp { };

  fdkaac =
    if pkgs ? "fdk-aac-encoder" then
      pkgs."fdk-aac-encoder"
    else if pkgs ? fdk_aac then
      pkgs.fdk_aac
    else
      throw "Neither fdk-aac-encoder nor fdk_aac is available in nixpkgs";

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
    fdkaac
    pkgs.opusTools
  ];

  runtimePath = lib.makeBinPath ([ dotnetRuntime ] ++ runtimeTools);
in
pkgs.stdenv.mkDerivation rec {
  pname = "amatsukaze";
  version = "1.0.6.3";

  src = pkgs.fetchFromGitHub {
    owner = "rigaya";
    repo = "Amatsukaze";
    tag = version;
    hash = "sha256-9Q4h9AbN45dDrn6fCV3sFVRK3iXmrQU2zzCjKRVW5Us=";
    fetchSubmodules = true;
  };

  strictDeps = true;

  nativeBuildInputs = with pkgs; [
    meson
    ninja
    pkg-config
    makeWrapper
    git
    dotnetSdk
  ];

  buildInputs = [
    ffmpeg
    pkgs.libjpeg_turbo
    pkgs.openssl
    pkgs.zlib
    avisynthplusCuda
    dotnetNugetDeps
  ]
  ++ dotnetSdk.packages;

  postPatch = ''
    substituteInPlace meson.build \
      --replace-fail 'version_full=$(git describe --tags) && \' 'version_full="${version}" && \' \
      --replace-fail 'version_short=$(git describe --abbrev=0 --tags) && \' 'version_short="${version}" && \'

    substituteInPlace AmatsukazeServer/Version.sh \
      --replace-fail '/bin/bash' '${pkgs.bash}/bin/bash' \
      --replace-fail 'VER=$(git describe --tags)' 'VER="${version}"'
  '';

  configurePhase = ''
    runHook preConfigure

    export HOME="$TMPDIR/home"
    mkdir -p "$HOME"

    meson setup build --buildtype release

    for project in \
      AmatsukazeServer/AmatsukazeServer.csproj \
      AmatsukazeServerCLI/AmatsukazeServerCLI.csproj \
      AmatsukazeAddTask/AmatsukazeAddTask.csproj \
      ScriptCommand/ScriptCommand.csproj; do
      dotnet restore "$project" \
        --runtime linux-x64 \
        -p:ContinuousIntegrationBuild=true \
        -p:Deterministic=true
    done

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    ninja -C build

    for project in \
      AmatsukazeServer/AmatsukazeServer.csproj \
      AmatsukazeServerCLI/AmatsukazeServerCLI.csproj \
      AmatsukazeAddTask/AmatsukazeAddTask.csproj \
      ScriptCommand/ScriptCommand.csproj; do
      dotnet build "$project" \
        --configuration Release \
        --runtime linux-x64 \
        --no-restore \
        -p:Platform=x64 \
        -p:UseAppHost=true \
        -p:ContinuousIntegrationBuild=true \
        -p:Deterministic=true
    done

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    exeDir="$out/lib/amatsukaze/exe_files"
    shareDir="$out/share/amatsukaze"

    mkdir -p "$out/bin" "$out/lib/amatsukaze" "$exeDir" "$shareDir"

    install -Dm755 build/AmatsukazeCLI/AmatsukazeCLI "$exeDir/AmatsukazeCLI"
    install -Dm755 build/Amatsukaze/libAmatsukaze.so "$exeDir/libAmatsukaze.so"

    cp -a x64/Release/. "$exeDir/"

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
      "${masktools}/lib" \
      "${mvtools}/lib" \
      "${rgtools}/lib" \
      "${yadifmod2}/lib" \
      "${tivtc}/lib"; do
      if [ -d "$pluginPath" ]; then
        for plugin in "$pluginPath"/*.so*; do
          ln -sf "$plugin" "$exeDir/plugins64/"
        done
      fi
    done

    makeWrapper "$exeDir/AmatsukazeCLI" "$out/bin/AmatsukazeCLI" \
      --prefix PATH : "${runtimePath}"

    makeWrapper "${dotnetRuntime}/bin/dotnet" "$out/bin/AmatsukazeServerCLI" \
      --set DOTNET_ROOT "${dotnetRuntime}/share/dotnet" \
      --prefix PATH : "${runtimePath}" \
      --add-flags "$exeDir/AmatsukazeServerCLI.dll"

    makeWrapper "${dotnetRuntime}/bin/dotnet" "$out/bin/AmatsukazeAddTask" \
      --set DOTNET_ROOT "${dotnetRuntime}/share/dotnet" \
      --prefix PATH : "${runtimePath}" \
      --add-flags "$exeDir/AmatsukazeAddTask.dll"

    makeWrapper "${dotnetRuntime}/bin/dotnet" "$out/bin/ScriptCommand" \
      --set DOTNET_ROOT "${dotnetRuntime}/share/dotnet" \
      --prefix PATH : "${runtimePath}" \
      --add-flags "$exeDir/ScriptCommand.dll"

    ln -s "$exeDir/libAmatsukaze.so" "$out/lib/libAmatsukaze.so"

    runHook postInstall
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
