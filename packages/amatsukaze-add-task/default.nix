{
  pkgs,
  perSystem,
  ...
}:
let
  common = import ../amatsukaze/common.nix { inherit pkgs perSystem; };
in
pkgs.buildDotnetModule {
  pname = "amatsukaze-add-task";
  inherit (common) version src;

  projectFile = "AmatsukazeAddTask/AmatsukazeAddTask.csproj";
  nugetDeps = common.dotnetNugetDeps;

  dotnet-sdk = common.dotnetSdk;
  dotnet-runtime = common.dotnetRuntime;

  selfContainedBuild = true;

  dotnetInstallFlags = [ "-p:PublishSingleFile=true" ];

  postPatch = common.dotnetVersionPatch;

  dotnetBuildFlags = [
    "-p:ContinuousIntegrationBuild=true"
    "-p:Deterministic=true"
  ];

  meta = with pkgs.lib; {
    description = "Task addition utility for Amatsukaze";
    homepage = "https://github.com/rigaya/Amatsukaze";
    license = licenses.mit;
    mainProgram = "AmatsukazeAddTask";
    platforms = [ "x86_64-linux" ];
  };
}
