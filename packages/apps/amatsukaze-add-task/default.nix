{
  lib,
  callPackage,
  buildDotnetModule,
  ...
}:
let
  common = callPackage ../amatsukaze/common.nix { };
in
buildDotnetModule {
  pname = "amatsukaze-add-task";
  inherit (common) version src;

  projectFile = "AmatsukazeAddTask/AmatsukazeAddTask.csproj";
  nugetDeps = ./deps.json;

  dotnet-sdk = common.dotnetSdk;
  dotnet-runtime = common.dotnetRuntime;

  selfContainedBuild = true;

  dotnetInstallFlags = [ "-p:PublishSingleFile=true" ];

  postPatch = common.dotnetVersionPatch;

  dotnetBuildFlags = [
    "-p:ContinuousIntegrationBuild=true"
    "-p:Deterministic=true"
  ];

  meta = with lib; {
    description = "Task addition utility for Amatsukaze";
    homepage = "https://github.com/rigaya/Amatsukaze";
    license = licenses.mit;
    mainProgram = "AmatsukazeAddTask";
    platforms = platforms.linux;
  };
}
