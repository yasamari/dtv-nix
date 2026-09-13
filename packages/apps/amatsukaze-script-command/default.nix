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
  pname = "amatsukaze-script-command";
  inherit (common) version src;

  projectFile = "ScriptCommand/ScriptCommand.csproj";
  nugetDeps = ../amatsukaze/deps.json;

  dotnet-sdk = common.dotnetSdk;
  dotnet-runtime = common.dotnetRuntime;

  enableParallelBuilding = false;

  selfContainedBuild = false;

  dontDotnetFixup = true;

  postPatch = common.dotnetVersionPatch;

  dotnetBuildFlags = [
    "-p:ContinuousIntegrationBuild=true"
    "-p:Deterministic=true"
  ];

  meta = with lib; {
    description = "Script command utility for Amatsukaze";
    homepage = "https://github.com/rigaya/Amatsukaze";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "ScriptCommand";
    platforms = [ "x86_64-linux" ];
  };
}
