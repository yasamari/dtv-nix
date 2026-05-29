{
  pkgs,
  perSystem,
  useLegacyQsvenc ? false,
  ...
}:
let
  common = import ./common.nix { inherit pkgs perSystem useLegacyQsvenc; };

  native = import ./native.nix { inherit pkgs common; };
  server = import ./server.nix { inherit pkgs common; };
  server-cli = import ./server-cli.nix { inherit pkgs common; };
  script-command = import ./script-command.nix { inherit pkgs common; };
  add-task = perSystem.self.amatsukaze-add-task;

  inherit (common) runtimePath cudaDriverLibraryPath;
in
pkgs.stdenv.mkDerivation {
  pname = "amatsukaze";
  inherit (common) version;

  inherit (common) src;

  nativeBuildInputs = [ pkgs.makeWrapper ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    exeDir="$out/lib/amatsukaze/exe_files"
    shareDir="$out/share/amatsukaze"

    mkdir -p "$out/bin" "$out/lib/amatsukaze" "$exeDir" "$shareDir"

    # Native binaries (libAmatsukaze.so, AmatsukazeCLI, AmatsukazeGenLogo)
    cp -a ${native}/lib/libAmatsukaze.so "$exeDir/"
    cp -a ${native}/bin/AmatsukazeCLI "$exeDir/"
    cp -a ${native}/bin/AmatsukazeGenLogo "$exeDir/"

    # .NET DLLs — each buildDotnetModule output is under $out/lib/<pname>/
    # First copy the server as base (most complete, includes shared deps + wwwroot)
    cp -a ${server}/lib/amatsukaze-server/. "$exeDir/"
    # Then pull in project-specific DLLs from the other components
    chmod -R u+w "$exeDir/"
    for dll in \
      AmatsukazeServerCLI.dll AmatsukazeServerCLI.runtimeconfig.json AmatsukazeServerCLI.deps.json \
      AmatsukazeServerCLI.pdb; do
      src="${server-cli}/lib/amatsukaze-server-cli/$dll"
      [ -f "$src" ] && cp -a "$src" "$exeDir/"
    done
    for dll in \
      ScriptCommand.dll ScriptCommand.runtimeconfig.json ScriptCommand.deps.json \
      ScriptCommand.pdb; do
      src="${script-command}/lib/amatsukaze-script-command/$dll"
      [ -f "$src" ] && cp -a "$src" "$exeDir/"
    done
    for dll in \
      AmatsukazeAddTask.dll AmatsukazeAddTask.runtimeconfig.json AmatsukazeAddTask.deps.json \
      AmatsukazeAddTask.pdb; do
      src="${add-task}/lib/amatsukaze-add-task/$dll"
      [ -f "$src" ] && cp -a "$src" "$exeDir/"
    done

    # Defaults, scripts, JL
    cp -a defaults/. "$shareDir/"
    mkdir -p "$shareDir/scripts"
    cp -a scripts/. "$shareDir/scripts/"
    cp -a "${common.joinLogoScp}/share/join_logo_scp/JL" "$shareDir/JL"

    # Plugins
    mkdir -p "$exeDir/plugins64"
    cp -a defaults/exe_files/plugins64/. "$exeDir/plugins64/"

    shopt -s nullglob
    for pluginPath in \
      "${common.avisynthplusCuda}/lib/avisynth" \
      "${common.avisynthcudafilters}/lib/avisynth" \
      "${common.nnedi3}/lib/avisynth" \
      "${common.masktools}/lib/avisynth" \
      "${common.mvtools}/lib/avisynth" \
      "${common.rgtools}/lib/avisynth" \
      "${common.yadifmod2}/lib/avisynth" \
      "${common.tivtc}/lib/avisynth"; do
      if [ -d "$pluginPath" ]; then
        for plugin in "$pluginPath"/*.so*; do
          ln -sf "$plugin" "$exeDir/plugins64/"
        done
      fi
    done

    ln -sf "${common.masktools}/lib/avisynth/libmasktools2.so" "$exeDir/plugins64/mt_masktools.so"

    # Wrappers
    makeWrapper "$exeDir/AmatsukazeCLI" "$out/bin/AmatsukazeCLI" \
      --prefix LD_LIBRARY_PATH : "${cudaDriverLibraryPath}" \
      --prefix PATH : "${runtimePath}"

    makeWrapper "$exeDir/AmatsukazeGenLogo" "$out/bin/AmatsukazeGenLogo" \
      --prefix LD_LIBRARY_PATH : "${cudaDriverLibraryPath}"

    makeWrapper "${common.dotnetRuntime}/bin/dotnet" "$out/bin/AmatsukazeServerCLI" \
      --set DOTNET_ROOT "${common.dotnetRuntime}/share/dotnet" \
      --prefix PATH : "$out/bin:${runtimePath}" \
      --add-flags "$exeDir/AmatsukazeServerCLI.dll"

    makeWrapper "${common.dotnetRuntime}/bin/dotnet" "$out/bin/ScriptCommand" \
      --set DOTNET_ROOT "${common.dotnetRuntime}/share/dotnet" \
      --prefix PATH : "${runtimePath}" \
      --add-flags "$exeDir/ScriptCommand.dll"

    ln -s "$exeDir/libAmatsukaze.so" "$out/lib/libAmatsukaze.so"
  '';

  meta = with pkgs.lib; {
    description = "Linux build of Amatsukaze server and CLI tools";
    homepage = "https://github.com/rigaya/Amatsukaze";
    changelog = "https://github.com/rigaya/Amatsukaze/releases/tag/${common.version}";
    license = licenses.mit;
    mainProgram = "AmatsukazeServerCLI";
    platforms = [ "x86_64-linux" ];
  };
}
