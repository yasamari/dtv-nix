{
  pkgs,
  ...
}:
let
  dotnetSdk = pkgs.dotnetCorePackages.sdk_10_0;
  dotnetRuntime = pkgs.dotnetCorePackages.aspnetcore_10_0;

  dotnetNugetDeps = pkgs.dotnetCorePackages.mkNugetDeps {
    name = "amatsukaze-add-task";
    sourceFile = ../amatsukaze/deps.json;
  };
in
pkgs.stdenv.mkDerivation rec {
  pname = "amatsukaze-add-task";
  version = "1.0.7.1";

  src = pkgs.fetchFromGitHub {
    owner = "rigaya";
    repo = "Amatsukaze";
    tag = version;
    hash = "sha256-qfRxxH/KToaieLZnDbjqGy++IITXZloAxI3+bAvwVA0=";
    fetchSubmodules = true;
  };

  postPatch = ''
    substituteInPlace AmatsukazeServer/Version.sh \
      --replace-fail '/bin/bash' '${pkgs.bash}/bin/bash' \
      --replace-fail 'VER=$(git describe --tags)' 'VER="${version}"'
  '';

  strictDeps = true;

  nativeBuildInputs = with pkgs; [
    makeWrapper
    dotnetSdk
  ];

  buildInputs = [
    dotnetNugetDeps
  ]
  ++ dotnetSdk.packages;

  configurePhase = ''
    runHook preConfigure

    export HOME="$TMPDIR/home"
    mkdir -p "$HOME"

    dotnet restore AmatsukazeAddTask/AmatsukazeAddTask.csproj \
      --runtime linux-x64 \
      -p:ContinuousIntegrationBuild=true \
      -p:Deterministic=true

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    dotnet build AmatsukazeAddTask/AmatsukazeAddTask.csproj \
      --configuration Release \
      --runtime linux-x64 \
      --no-restore \
      -p:Platform=x64 \
      -p:UseAppHost=true \
      -p:ContinuousIntegrationBuild=true \
      -p:Deterministic=true

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    exeDir="$out/lib/amatsukaze-add-task"

    mkdir -p "$out/bin" "$exeDir"

    dotnetOutputDir=""
    for dir in x64/Release x64/Release/net* x64/Release/net*/linux-x64; do
      if [ -f "$dir/AmatsukazeAddTask.dll" ]; then
        dotnetOutputDir="$dir"
        break
      fi
    done

    if [ -z "$dotnetOutputDir" ]; then
      echo "Failed to locate AmatsukazeAddTask.dll under x64/Release" >&2
      exit 1
    fi

    cp -a "$dotnetOutputDir"/. "$exeDir/"

    makeWrapper "${dotnetRuntime}/bin/dotnet" "$out/bin/AmatsukazeAddTask" \
      --set DOTNET_ROOT "${dotnetRuntime}/share/dotnet" \
      --add-flags "$exeDir/AmatsukazeAddTask.dll"

    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "Task addition utility for Amatsukaze";
    homepage = "https://github.com/rigaya/Amatsukaze";
    license = licenses.mit;
    mainProgram = "AmatsukazeAddTask";
    platforms = [ "x86_64-linux" ];
  };
}
