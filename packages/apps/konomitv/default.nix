{
  lib,
  stdenv,
  callPackage,
  python3,
  opencv,
  ffmpeg,
  chromium,
  akebi,
  tsreadex,
  psisiarc,
  psisimux,
  qsvenc ? null,
  nvenc ? null,
  asyncio-atexit,
  hashids,
  grapheme,
  ariblib,
  biim,
  pypika-tortoise,
  tortoise-orm,
  aerich,
  zendriver,
  atproto,
  ...
}:
let
  inherit (callPackage ./source.nix { }) version konomitvSrc;

  python = python3;
  py = python.pkgs;

  clientBundle = callPackage ../konomitv-client { };

  dependencies = [
    aerich
    ariblib
    biim
    hashids
    tortoise-orm
    zendriver
    atproto
    py.aiofiles
    py.aiohttp
    py.av
    py.bcrypt
    py.beautifulsoup4
    py.colorama
    py.cryptography
    py.elevate
    py.fastapi
    py.h2
    py.httpx
    py.httptools
    py."opencv-python-headless"
    py.passlib
    py.pillow
    py.ping3
    py.psutil
    py.puremagic
    py.py7zr
    py.pydantic
    py."python-jose"
    py."python-multipart"
    py.requests
    py.rich
    py."ruamel-yaml"
    py."sse-starlette"
    py.typer
    py."typing-extensions"
    py."typing-inspect"
    py.tzdata
    py.uvicorn
    py.uvloop
    py.watchfiles
    py.websockets
  ];

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
in
py.buildPythonApplication rec {
  pname = "konomitv";
  inherit version;

  sourceRoot = "source/server";
  format = "pyproject";

  src = konomitvSrc;

  propagatedBuildInputs = dependencies;

  nativeBuildInputs = [ py.poetry-core ];

  pythonRelaxDeps = [
    "aiofiles"
    "atproto"
    "av"
    "bcrypt"
    "fastapi"
    "pillow"
    "ping3"
    "psutil"
    "py7zr"
    "rich"
    "ruamel-yaml"
    "sse-starlette"
    "tzdata"
  ];

  pythonRemoveDeps = [ "taskipy" ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'package-mode = false' $'package-mode = true\npackages = [{ include = "app" }]\n'

    cat >> pyproject.toml <<'EOF'

    [tool.poetry.scripts]
    konomitv = "KonomiTV:cli"
    EOF

    substituteInPlace pyproject.toml \
      --replace-fail '"ruamel.yaml" = "==0.18.12"' '"ruamel.yaml" = ">=0.18.12,<0.20.0"'

    # アーキテクチャとサードパーティーライブラリのチェックに失敗しても動作するようにする。
    substituteInPlace KonomiTV.py --replace-fail "sys.exit(1)" ""

    # パスの解決に失敗している箇所を修正する。
    substituteInPlace KonomiTV.py \
      --replace-fail "location='./app/migrations/'" "location=str(Path(__file__).resolve().parent / 'app/migrations')"
    substituteInPlace app/constants.py \
      --replace-fail "path=['app/models']" \
      "path=[str(Path(__file__).resolve().parent / 'models')]"

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
      "STATIC_DIR = Path('${src}/server/static')"
      
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
  '';

  postInstall = ''
    install -Dm644 ../config.example.yaml "$out/share/konomitv/config.example.yaml"
    install -Dm644 ../License.txt "$out/share/konomitv/License.txt"
    install -Dm644 ${./config.yaml} "$out/share/konomitv/config.yaml"

    install -Dm644 KonomiTV.py "$out/${python.sitePackages}/KonomiTV.py"
  '';

  makeWrapperArgs = [
    ''--prefix PATH : "${chromium}/bin"''
  ];

  meta = with lib; {
    description = "Modern Japanese TV media server";
    homepage = "https://github.com/tsukumijima/KonomiTV";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "konomitv";
    platforms = platforms.linux;
  };
}
