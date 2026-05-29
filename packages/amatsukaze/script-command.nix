{ pkgs, common }:
pkgs.buildDotnetModule {
  pname = "amatsukaze-script-command";
  inherit (common) version src;

  projectFile = "ScriptCommand/ScriptCommand.csproj";
  nugetDeps = common.dotnetNugetDeps;

  dotnet-sdk = common.dotnetSdk;
  dotnet-runtime = common.dotnetRuntime;

  selfContainedBuild = false;

  postPatch = common.dotnetVersionPatch;

  dotnetBuildFlags = [
    "-p:ContinuousIntegrationBuild=true"
    "-p:Deterministic=true"
  ];

  meta = with pkgs.lib; {
    description = "Amatsukaze script command utility";
    homepage = "https://github.com/rigaya/Amatsukaze";
    license = licenses.mit;
    mainProgram = "ScriptCommand";
    platforms = [ "x86_64-linux" ];
  };
}
