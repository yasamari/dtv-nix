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
  pname = "amatsukaze-webui";
  inherit (common) version src;

  projectFile = "AmatsukazeWebUI/AmatsukazeWebUI.csproj";
  nugetDeps = ../amatsukaze/deps.json;

  dotnet-sdk = common.dotnetSdk;
  dotnet-runtime = common.dotnetRuntime;

  enableParallelBuilding = false;

  # The WebUI ships static files only; generating an apphost executable for
  # the browser-wasm RID is impossible (NETSDK1084).
  useAppHost = false;

  dontDotnetFixup = true;

  # The Blazor workload demands a Mono.linux-x64 pack that was never
  # published, so the hook's default restore (always `--runtime <rid>`)
  # fails with NU1102. Restore without --runtime instead; the offline NuGet
  # wiring (local source + fallback folders) is already set up by
  # configureNuget, so this stays hermetic.
  configurePhase = ''
    runHook preConfigure

    dotnet restore $dotnetProjectFiles \
      -p:ContinuousIntegrationBuild=true \
      -p:Deterministic=true \
      -p:NuGetAudit=false

    runHook postConfigure
  '';

  dotnetBuildFlags = [
    "-p:ContinuousIntegrationBuild=true"
    "-p:Deterministic=true"
  ];

  # Publish exactly like upstream's nested PublishWebUI step does
  # (`dotnet publish -c Release -o <dir>` with no extra flags): the hook's
  # publish would force `--runtime linux-x64 --no-self-contained`, which the
  # Blazor workload cannot satisfy (WASM0005). The implicit restore stays
  # offline through the configureNuget wiring.
  installPhase = ''
    runHook preInstall

    dotnet publish $dotnetProjectFiles \
      --configuration Release \
      --output "$out/share/amatsukaze-webui"

    runHook postInstall
  '';

  postInstall = ''
    # Keep only the static files served by the server.
    mv "$out/share/amatsukaze-webui/wwwroot" "$out/share/amatsukaze-webui-wwwroot"
    rm -rf "$out/share/amatsukaze-webui"
    mv "$out/share/amatsukaze-webui-wwwroot" "$out/share/amatsukaze-webui"
  '';

  meta = with lib; {
    description = "Amatsukaze WebUI static files (Blazor WebAssembly)";
    homepage = "https://github.com/rigaya/Amatsukaze";
    license = licenses.mit;
    maintainers = [ ];
    # Content is arch-independent, but kept in the x86_64-only family
    # alongside the server that serves it.
    platforms = [ "x86_64-linux" ];
  };
}
