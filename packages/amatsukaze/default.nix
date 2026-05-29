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
  dontStrip = true;

  installPhase = ''
    exeDir="$out/lib/amatsukaze/exe_files"
    shareDir="$out/share/amatsukaze"

    mkdir -p "$out/bin" "$out/lib/amatsukaze" "$exeDir" "$shareDir"

    # Native binaries (libAmatsukaze.so, AmatsukazeCLI, AmatsukazeGenLogo)
    cp -a ${native}/lib/libAmatsukaze.so "$exeDir/"
    cp -a ${native}/bin/AmatsukazeCLI "$exeDir/"
    cp -a ${native}/bin/AmatsukazeGenLogo "$exeDir/"

    # Self-contained .NET binaries (PublishSingleFile=true)
    cp -a ${server-cli}/lib/amatsukaze-server-cli/AmatsukazeServerCLI "$exeDir/"
    cp -a ${script-command}/lib/amatsukaze-script-command/ScriptCommand "$exeDir/"
    cp -a ${add-task}/lib/amatsukaze-add-task/AmatsukazeAddTask "$exeDir/"

    # WebUI static files (extracted from AmatsukazeServer.dll publish)
    cp -a ${server}/lib/amatsukaze-server/wwwroot "$exeDir/wwwroot"

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

    makeWrapper "$exeDir/AmatsukazeServerCLI" "$out/bin/AmatsukazeServerCLI" \
      --prefix LD_LIBRARY_PATH : "${cudaDriverLibraryPath}" \
      --prefix PATH : "$out/bin:${runtimePath}"

    ln -s "$exeDir/ScriptCommand" "$out/bin/ScriptCommand"
    ln -s "$exeDir/AmatsukazeAddTask" "$out/bin/AmatsukazeAddTask"

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
