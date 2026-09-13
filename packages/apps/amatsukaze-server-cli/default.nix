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
  pname = "amatsukaze-server-cli";
  inherit (common) version src;

  projectFile = "AmatsukazeServerCLI/AmatsukazeServerCLI.csproj";
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
    description = "Amatsukaze server command line interface";
    homepage = "https://github.com/rigaya/Amatsukaze";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "AmatsukazeServerCLI";
    platforms = [ "x86_64-linux" ];
  };
}
