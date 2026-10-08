{
  lib,
  stdenv,
  callPackage,
  python313,
  uv2nix,
  pyproject-nix,
  pyproject-build-systems,
  opencv,
  ffmpeg,
  chromium,
  akebi,
  tsreadex,
  psisiarc,
  psisimux,
  makeWrapper,
  runCommand,
  qsvenc ? null,
  nvenc ? null,
  nix-update-script,
  ...
}:
let
  inherit (callPackage ./source.nix { }) version konomitvSrc;

  python = python313;

  clientBundle = callPackage ../konomitv-client { };

  # QSVEnc/NVEnc are x86_64-only; never touch them on other systems so that
  # merely evaluating this package does not pull in unsupported derivations.
  # Null means "encoder not available" (e.g. via `.override { qsvenc = null; }`).
  # The arch guard must come after the null check so that a null override on
  # x86_64 never stringifies null, and so that merely evaluating this package
  # on other architectures does not pull the x86_64-only encoders in.
  qsvenccPath =
    if qsvenc == null then
      ""
    else if stdenv.hostPlatform.isx86_64 then
      "${qsvenc}/bin/qsvencc"
    else
      "";
  nvenccPath =
    if nvenc == null then
      ""
    else if stdenv.hostPlatform.isx86_64 then
      "${nvenc}/bin/nvencc"
    else
      "";

  patchedSrc = runCommand "konomitv-src-patched" { } ''
    cp -r ${konomitvSrc} source
    chmod -R u+w source
    (cd source/server && {

    # パスの解決に失敗している箇所を修正する。
    substituteInPlace KonomiTV.py \
      --replace-fail "location='./app/migrations/'" "location=str(Path(__file__).resolve().parent / 'app/migrations')"
    substituteInPlace app/constants.py \
      --replace-fail "path=['app/models']" \
      "path=[str(Path(__file__).resolve().parent / 'models')]"

    # アーキテクチャとサードパーティーライブラリのチェックに失敗しても動作するようにする。
    substituteInPlace KonomiTV.py --replace-fail "sys.exit(1)" ""

    # OpenCV のカスケード分類器のパスを修正する。
    substituteInPlace app/metadata/ThumbnailGenerator.py \
      --replace-fail \
      "pathlib.Path(cv2.__file__).parent / 'data' / 'haarcascade_frontalface_default.xml'" \
      "pathlib.Path('${opencv}/share/opencv4/haarcascades/haarcascade_frontalface_default.xml')"

    # os のインポートを追加する。
    substituteInPlace app/config.py app/constants.py \
      --replace-fail "import sys" "import sys${"\n"}import os"

    # 設定ファイルのパスを環境変数で設定できるように変更する。
    substituteInPlace app/config.py \
      --replace-fail \
      "_CONFIG_YAML_PATH = BASE_DIR.parent / 'config.yaml'" \
      "_CONFIG_YAML_PATH = Path(os.getenv('KONOMITV_CONFIG_YAML_PATH', str(Path.cwd() / 'config.yaml')))"

    # クライアントバンドルと静的ファイルのパスを直接指定する。
    substituteInPlace app/constants.py \
      --replace-fail \
      "CLIENT_DIR = BASE_DIR.parent / 'client/dist'" \
      "CLIENT_DIR = Path('${clientBundle}')" \
      --replace-fail \
      "STATIC_DIR = BASE_DIR / 'static'" \
      "STATIC_DIR = Path('${konomitvSrc}/server/static')"

    # データとログのディレクトリを環境変数で指定できるように変更し、存在しない場合は作成するようにする。
    substituteInPlace app/constants.py \
      --replace-fail \
      "DATA_DIR = BASE_DIR / 'data'" \
      "DATA_DIR = Path(os.getenv('KONOMITV_DATA_DIR', str(Path.cwd() / 'data')))${"\n"}DATA_DIR.mkdir(parents=True, exist_ok=True)" \
      --replace-fail \
      "LOGS_DIR = BASE_DIR / 'logs'" \
      "LOGS_DIR = Path(os.getenv('KONOMITV_LOGS_DIR', str(Path.cwd() / 'logs')))${"\n"}LOGS_DIR.mkdir(parents=True, exist_ok=True)" \
      --replace-fail \
      "ACCOUNT_ICON_DIR = DATA_DIR / 'account-icons'" \
      "ACCOUNT_ICON_DIR = DATA_DIR / 'account-icons'${"\n"}ACCOUNT_ICON_DIR.mkdir(parents=True, exist_ok=True)" \
      --replace-fail \
      "THUMBNAILS_DIR = DATA_DIR / 'thumbnails'" \
      "THUMBNAILS_DIR = DATA_DIR / 'thumbnails'${"\n"}THUMBNAILS_DIR.mkdir(parents=True, exist_ok=True)"

    # サードパーティーライブラリのパスを直接指定する。VCEEncC と rkmppenc はパッケージ化できていないため環境変数で指定できるようにする。
    substituteInPlace app/constants.py \
      --replace-fail \
      "str(LIBRARY_DIR / 'Akebi/akebi-https-server') + LIBRARY_EXTENSION" \
      "'${akebi}/bin/akebi-https-server'" \
      --replace-fail \
      "str(LIBRARY_DIR / 'tsreadex/tsreadex') + LIBRARY_EXTENSION" \
      "'${tsreadex}/bin/tsreadex'" \
      --replace-fail \
      "str(LIBRARY_DIR / 'psisiarc/psisiarc') + LIBRARY_EXTENSION" \
      "'${psisiarc}/bin/psisiarc'" \
      --replace-fail \
      "str(LIBRARY_DIR / 'psisimux/psisimux') + LIBRARY_EXTENSION" \
      "'${psisimux}/bin/psisimux'" \
      --replace-fail \
      "str(LIBRARY_DIR / 'FFmpeg/ffmpeg') + LIBRARY_EXTENSION" \
      "'${ffmpeg}/bin/ffmpeg'" \
      --replace-fail \
      "str(LIBRARY_DIR / 'FFmpeg/ffprobe') + LIBRARY_EXTENSION" \
      "'${ffmpeg}/bin/ffprobe'" \
      --replace-fail \
      "str(LIBRARY_DIR / 'QSVEncC/QSVEncC') + LIBRARY_EXTENSION" \
      "'${qsvenccPath}'" \
      --replace-fail \
      "str(LIBRARY_DIR / 'NVEncC/NVEncC') + LIBRARY_EXTENSION" \
      "'${nvenccPath}'" \
      --replace-fail \
      "str(LIBRARY_DIR / 'VCEEncC/VCEEncC') + LIBRARY_EXTENSION" \
      "os.getenv('KONOMITV_VCEENCC_PATH', str(Path.cwd() / 'thirdparty/vceencc.elf'))" \
      --replace-fail \
      "str(LIBRARY_DIR / 'rkmppenc/rkmppenc') + LIBRARY_EXTENSION" \
      "os.getenv('KONOMITV_RKMPPENC_PATH', str(Path.cwd() / 'thirdparty/rkmppenc.elf'))"

    })

    mv source $out
  '';

  workspace = uv2nix.lib.workspace.loadWorkspace {
    workspaceRoot = "${patchedSrc}/server";
  };

  overlay = workspace.mkPyprojectOverlay {
    sourcePreference = "wheel";
  };

  pythonSet = (callPackage pyproject-nix.build.packages { inherit python; }).overrideScope (
    lib.composeManyExtensions [
      pyproject-build-systems.overlays.wheel
      overlay
      # sdist-only packages that fail to declare their build requirements
      (final: prev: {
        elevate = prev.elevate.overrideAttrs (old: {
          nativeBuildInputs = old.nativeBuildInputs ++ final.resolveBuildSystem { setuptools = [ ]; };
        });
        grapheme = prev.grapheme.overrideAttrs (old: {
          nativeBuildInputs = old.nativeBuildInputs ++ final.resolveBuildSystem { setuptools = [ ]; };
        });
      })
    ]
  );

  venv = pythonSet.mkVirtualEnv "konomitv-${version}" workspace.deps.default;
in
stdenv.mkDerivation {
  pname = "konomitv";
  inherit version;

  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/konomitv
    cp -r ${patchedSrc}/server $out/share/konomitv/server
    install -Dm644 ${konomitvSrc}/config.example.yaml $out/share/konomitv/config.example.yaml
    install -Dm644 ${konomitvSrc}/License.txt $out/share/konomitv/License.txt
    install -Dm644 ${./config.yaml} $out/share/konomitv/config.yaml

    makeWrapper ${venv}/bin/python $out/bin/konomitv \
      --add-flags "$out/share/konomitv/server/KonomiTV.py" \
      --prefix PATH : "${chromium}/bin"

    runHook postInstall
  '';

  strictDeps = true;

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--flake"
      "--version=branch=master"
      "--override-filename"
      "packages/apps/konomitv/source.nix"
    ];
  };

  meta = with lib; {
    description = "Modern Japanese TV media server";
    homepage = "https://github.com/tsukumijima/KonomiTV";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "konomitv";
    platforms = platforms.linux;
  };
}
