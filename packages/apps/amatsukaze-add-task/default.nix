{
  lib,
  callPackage,
  buildDotnetModule,
  makeWrapper,
  ...
}:
let
  common = callPackage ../amatsukaze/common.nix { };
in
buildDotnetModule {
  pname = "amatsukaze-add-task";
  inherit (common) version src;

  projectFile = "AmatsukazeAddTask/AmatsukazeAddTask.csproj";
  nugetDeps = ../amatsukaze/deps.json;

  dotnet-sdk = common.dotnetSdk;
  dotnet-runtime = common.dotnetRuntime;

  enableParallelBuilding = false;

  selfContainedBuild = false;

  dontDotnetFixup = true;

  nativeBuildInputs = [ makeWrapper ];

  postPatch = common.dotnetVersionPatch;

  dotnetBuildFlags = [
    "-p:ContinuousIntegrationBuild=true"
    "-p:Deterministic=true"
  ];

  postInstall = ''
    makeWrapper "$out/lib/amatsukaze-add-task/AmatsukazeAddTask" "$out/bin/AmatsukazeAddTask" \
      --set DOTNET_ROOT "${common.dotnetRuntime}/share/dotnet"
  '';

  meta = with lib; {
    description = "Task addition utility for Amatsukaze";
    homepage = "https://github.com/rigaya/Amatsukaze";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "AmatsukazeAddTask";
    platforms = platforms.linux;
  };
}
