{ pkgs, common }:
pkgs.buildDotnetModule {
  pname = "amatsukaze-server-cli";
  inherit (common) version src;

  projectFile = "AmatsukazeServerCLI/AmatsukazeServerCLI.csproj";
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
    description = "Amatsukaze server CLI";
    homepage = "https://github.com/rigaya/Amatsukaze";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
  };
}
