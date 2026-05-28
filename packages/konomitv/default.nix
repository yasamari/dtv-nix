{
  perSystem,
  pkgs,
  useLegacyQsvenc ? false,
  ...
}:
let
  version = "master-2026-05-11";

  konomitvSrc = pkgs.fetchFromGitHub {
    owner = "tsukumijima";
    repo = "KonomiTV";
    rev = "a4caed43b6e26eb493b38464d3f975556377865e";
    hash = "sha256-O3Ht8c8AdUE+B766CBiDXqBigkcBLEeNQgsmIizczHw=";
  };

  clientBundle = import ./client-bundle.nix {
    inherit pkgs konomitvSrc version;
  };

  pythonEnv = import ./python.nix {
    inherit pkgs;
  };

  akebi = perSystem.self.akebi;
  psisimux = perSystem.self.psisimux;
  tsreadex = perSystem.self.tsreadex;
  psisiarc = perSystem.self.psisiarc;
  qsvenc =
    if pkgs.stdenv.hostPlatform.isx86_64 then
      if useLegacyQsvenc then perSystem.self."qsvenc-legacy" else perSystem.self.qsvenc
    else
      null;
  nvenc = if pkgs.stdenv.hostPlatform.isx86_64 then perSystem.self.nvenc else null;

  headlessBrowser = pkgs.chromium;

  konomitvWrapper = pkgs.writeShellScript "konomitv" ''
    set -eo pipefail

    script_dir="$(${pkgs.coreutils}/bin/dirname "$(${pkgs.coreutils}/bin/readlink -f "$0")")"
    template_dir="$script_dir/../share/konomitv"

    if [ -n "$XDG_STATE_HOME" ]; then
      state_root="$XDG_STATE_HOME/konomitv"
    else
      state_root="$HOME/.local/state/konomitv"
    fi

    if [ -z "$KONOMITV_CONFIG_YAML_PATH" ]; then
      KONOMITV_CONFIG_YAML_PATH="$state_root/config.yaml"
    fi

    if [ -z "$KONOMITV_DATA_DIR" ]; then
      KONOMITV_DATA_DIR="$state_root/data"
    fi

    if [ -z "$KONOMITV_LOGS_DIR" ]; then
      KONOMITV_LOGS_DIR="$state_root/logs"
    fi

    config_dir="$(${pkgs.coreutils}/bin/dirname "$KONOMITV_CONFIG_YAML_PATH")"

    mkdir -p \
      "$config_dir" \
      "$KONOMITV_DATA_DIR" \
      "$KONOMITV_DATA_DIR/account-icons" \
      "$KONOMITV_DATA_DIR/thumbnails" \
      "$KONOMITV_LOGS_DIR"

    if [ ! -e "$KONOMITV_CONFIG_YAML_PATH" ]; then
      cp "$template_dir/config.yaml" "$KONOMITV_CONFIG_YAML_PATH"
    fi

    export KONOMITV_CONFIG_YAML_PATH
    export KONOMITV_DATA_DIR
    export KONOMITV_LOGS_DIR
    export PATH="${headlessBrowser}/bin:$PATH"

    cd "$template_dir/server"
    exec "${pythonEnv}/bin/python" KonomiTV.py "$@"
  '';
in
pkgs.stdenv.mkDerivation rec {
  pname = "konomitv";
  inherit version;

  src = konomitvSrc;

  patches = [
    ./konomitv-immutable-paths.patch
  ];

  nativeBuildInputs = [ pkgs.makeWrapper ];

  dontBuild = true;

  postPatch = ''
    substituteInPlace server/KonomiTV.py --replace-fail "sys.exit(1)" ""

    substituteInPlace server/app/metadata/ThumbnailGenerator.py \
      --replace-fail \
      "pathlib.Path(cv2.__file__).parent / 'data' / 'haarcascade_frontalface_default.xml'" \
      "pathlib.Path('${pkgs.opencv}/share/opencv4/haarcascades/haarcascade_frontalface_default.xml')"
  '';

  installPhase = ''
    runHook preInstall

    shareDir="$out/share/konomitv"
    thirdpartyDir="$shareDir/server/thirdparty"

    mkdir -p "$out/bin" "$shareDir"
    cp -a server "$shareDir/server"
    cp -a client "$shareDir/client"
    rm -rf "$shareDir/client/dist"
    mkdir -p "$shareDir/client/dist"
    cp -a "${clientBundle}/." "$shareDir/client/dist/"
    install -Dm644 config.example.yaml "$shareDir/config.example.yaml"
    install -Dm644 config.example.yaml "$shareDir/config.yaml"
    install -Dm644 License.txt "$shareDir/License.txt"

    mkdir -p \
      "$thirdpartyDir/Akebi" \
      "$thirdpartyDir/FFmpeg" \
      "$thirdpartyDir/QSVEncC" \
      "$thirdpartyDir/NVEncC" \
      "$thirdpartyDir/VCEEncC" \
      "$thirdpartyDir/rkmppenc" \
      "$thirdpartyDir/tsreadex" \
      "$thirdpartyDir/psisiarc" \
      "$thirdpartyDir/psisimux"

    ln -s "${akebi}/bin/akebi-https-server" "$thirdpartyDir/Akebi/akebi-https-server.elf"
    ln -s "${pkgs.ffmpeg}/bin/ffmpeg" "$thirdpartyDir/FFmpeg/ffmpeg.elf"
    ln -s "${pkgs.ffmpeg}/bin/ffprobe" "$thirdpartyDir/FFmpeg/ffprobe.elf"
    ln -s "${tsreadex}/bin/tsreadex" "$thirdpartyDir/tsreadex/tsreadex.elf"
    ln -s "${psisiarc}/bin/psisiarc" "$thirdpartyDir/psisiarc/psisiarc.elf"
    ln -s "${psisimux}/bin/psisimux" "$thirdpartyDir/psisimux/psisimux.elf"

    ${pkgs.lib.optionalString pkgs.stdenv.hostPlatform.isx86_64 ''
      ln -s "${qsvenc}/bin/qsvencc" "$thirdpartyDir/QSVEncC/QSVEncC.elf"
      ln -s "${nvenc}/bin/nvencc" "$thirdpartyDir/NVEncC/NVEncC.elf"
    ''}

    install -Dm755 "${konomitvWrapper}" "$out/bin/konomitv"

    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "Modern Japanese TV media server";
    homepage = "https://github.com/tsukumijima/KonomiTV";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "konomitv";
    platforms = platforms.linux;
  };
}
