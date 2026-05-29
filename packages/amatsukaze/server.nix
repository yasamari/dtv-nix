{ pkgs, common }:
pkgs.buildDotnetModule {
  pname = "amatsukaze-server";
  inherit (common) version src;

  projectFile = "AmatsukazeServer/AmatsukazeServer.csproj";
  nugetDeps = common.dotnetNugetDeps;

  dotnet-sdk = common.dotnetSdk;
  dotnet-runtime = common.dotnetRuntime;

  selfContainedBuild = false;

  dontDotnetFixup = true;

  postPatch = common.dotnetVersionPatch + ''
    substituteInPlace AmatsukazeServer/Server/EncodeServer.cs \
      --replace-fail 'setting.AmatsukazePath = Path.Combine(basePath, "AmatsukazeCLI" + exeDefaultAppendix);' 'setting.AmatsukazePath = "AmatsukazeCLI";'
  '';

  dotnetBuildFlags = [
    "-p:ContinuousIntegrationBuild=true"
    "-p:Deterministic=true"
  ];

  meta = with pkgs.lib; {
    description = "Amatsukaze .NET server library and WebUI";
    homepage = "https://github.com/rigaya/Amatsukaze";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
  };
}
