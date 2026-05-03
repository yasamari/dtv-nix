{
  perSystem,
  pkgs,
  useLegacyQsvenc ? false,
  ...
}:
let
  lib = pkgs.lib;
  python = pkgs.python313;
  py = python.pkgs;

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

  asyncioAtexit = py.buildPythonPackage rec {
    pname = "asyncio-atexit";
    version = "1.0.1";
    format = "setuptools";

    src = pkgs.fetchPypi {
      inherit pname version;
      hash = "sha256-HQxxVEuO4sSE0yKETucsCHXd5vJQwO1baZNZKrn31DY=";
    };

    nativeBuildInputs = [
      py.setuptools
      py.wheel
    ];

    doCheck = false;
    pythonImportsCheck = [ "asyncio_atexit" ];

    meta = with lib; {
      description = "Like atexit, but for asyncio";
      homepage = "https://github.com/minrk/asyncio-atexit";
      license = licenses.mit;
    };
  };

  hashids = py.buildPythonPackage rec {
    pname = "hashids";
    version = "1.3.1";
    format = "pyproject";

    src = pkgs.fetchPypi {
      inherit pname version;
      hash = "sha256-bD3HdeZe/CziwVemWst3bWNMuBRZj0BkaavvAK4/Y1w=";
    };

    nativeBuildInputs = [ py."flit-core" ];

    doCheck = false;
    pythonImportsCheck = [ "hashids" ];

    meta = with lib; {
      description = "Small open-source library that generates short hashes";
      homepage = "https://github.com/davidaurelio/hashids-python";
      license = licenses.mit;
    };
  };

  grapheme = py.buildPythonPackage rec {
    pname = "grapheme";
    version = "0.6.0";
    format = "setuptools";

    src = pkgs.fetchPypi {
      inherit pname version;
      hash = "sha256-RMK58hu+d8+wWDX+wjC9Q1lUJ1Jn/qGFgBOxAvhgPMo=";
    };

    nativeBuildInputs = [ py.setuptools ];

    doCheck = false;
    pythonImportsCheck = [ "grapheme" ];

    meta = with lib; {
      description = "Unicode grapheme helpers";
      homepage = "https://github.com/alvinlindstam/grapheme";
      license = licenses.mit;
    };
  };

  ariblib = py.buildPythonPackage rec {
    pname = "ariblib";
    version = "0.1.4";
    format = "setuptools";

    src = pkgs.fetchFromGitHub {
      owner = "tsukumijima";
      repo = "ariblib";
      rev = "af6b7127692a4f26310756f09b4c81380fd3d750";
      hash = "sha256-P1JsZwymnenKwH/yiLVa3SU2f3H/A9izZl4tm5w+UNU=";
    };

    nativeBuildInputs = [ py.setuptools ];

    doCheck = false;
    pythonImportsCheck = [ "ariblib" ];

    meta = with lib; {
      description = "Python implementation of ARIB STD-B10/B24";
      homepage = "https://github.com/tsukumijima/ariblib";
      license = licenses.mit;
    };
  };

  biim = py.buildPythonPackage rec {
    pname = "biim";
    version = "1.11.0.post1";
    format = "pyproject";

    src = pkgs.fetchFromGitHub {
      owner = "tsukumijima";
      repo = "biim";
      rev = "73dd9b08fd5161f6ea8827e5671fa96e0be57c4d";
      hash = "sha256-EJn3U+0LrIye+cppWmPQ1YV3pswg0vII6WkfV6b2zJI=";
    };

    nativeBuildInputs = [ py.hatchling ];

    propagatedBuildInputs = [ py.aiohttp ];

    doCheck = false;
    pythonImportsCheck = [ "biim" ];

    meta = with lib; {
      description = "LL-HLS implementation written in Python";
      homepage = "https://github.com/tsukumijima/biim";
      license = licenses.mit;
    };
  };

  pypikaTortoise = py.buildPythonPackage rec {
    pname = "pypika-tortoise";
    version = "0.6.5";
    format = "pyproject";

    src = pkgs.fetchPypi {
      pname = "pypika_tortoise";
      inherit version;
      hash = "sha256-ZNlsm4hFD2NgrSKnBjkztqkJYacxfwSytjyY/V1wVQY=";
    };

    nativeBuildInputs = [ py."pdm-backend" ];

    doCheck = false;
    pythonImportsCheck = [ "pypika_tortoise" ];

    meta = with lib; {
      description = "PyPika fork streamlined for Tortoise ORM";
      homepage = "https://github.com/tortoise/pypika-tortoise";
      license = licenses.asl20;
    };
  };

  tortoiseOrm = py.buildPythonPackage rec {
    pname = "tortoise-orm";
    version = "0.25.4";
    format = "pyproject";

    src = pkgs.fetchPypi {
      pname = "tortoise_orm";
      inherit version;
      hash = "sha256-iMIx6+FY8Sh/yclJcxP5pGz7cLZsRYujmQCSGk5S0Bs=";
    };

    nativeBuildInputs = [ py."pdm-backend" ];

    propagatedBuildInputs = [
      pypikaTortoise
      py.iso8601
      py.aiosqlite
      py.anyio
      py.pytz
    ];

    doCheck = false;
    pythonImportsCheck = [ "tortoise" ];

    meta = with lib; {
      description = "Easy async ORM for Python";
      homepage = "https://github.com/tortoise/tortoise-orm";
      license = licenses.asl20;
    };
  };

  aerich = py.buildPythonPackage rec {
    pname = "aerich";
    version = "0.9.1";
    format = "pyproject";

    src = pkgs.fetchPypi {
      inherit pname version;
      hash = "sha256-Ypr771kCY1xB9BDdBd75hMAuBeYtiiAgIQoppKrhkAE=";
    };

    nativeBuildInputs = [ py."poetry-core" ];

    propagatedBuildInputs = [
      tortoiseOrm
      py.pydantic
      py.dictdiffer
      py.asyncclick
      py."tomli-w"
    ];

    doCheck = false;
    pythonImportsCheck = [ "aerich" ];

    meta = with lib; {
      description = "Database migrations tool for Tortoise ORM";
      homepage = "https://github.com/tortoise/aerich";
      license = licenses.asl20;
      mainProgram = "aerich";
    };
  };

  zendriver = py.buildPythonPackage rec {
    pname = "zendriver";
    version = "0.15.3";
    format = "pyproject";

    src = pkgs.fetchPypi {
      inherit pname version;
      hash = "sha256-g8OP4XSJNw8MOB37iw1NC7n153VcV0jJnXK/mIb1nu4=";
    };

    nativeBuildInputs = [ py.hatchling ];

    propagatedBuildInputs = [
      asyncioAtexit
      py.deprecated
      py.emoji
      grapheme
      py.mss
      py.websockets
    ];

    doCheck = false;
    pythonImportsCheck = [ "zendriver" ];

    meta = with lib; {
      description = "Async browser automation via Chrome DevTools Protocol";
      homepage = "https://github.com/cdpdriver/zendriver";
      license = licenses.agpl3Only;
    };
  };

  pythonEnv = python.withPackages (_: [
    aerich
    ariblib
    biim
    hashids
    tortoiseOrm
    zendriver
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
  ]);
in
pkgs.stdenv.mkDerivation rec {
  pname = "konomitv";
  version = "master-2026-05-01";

  src = pkgs.fetchFromGitHub {
    owner = "tsukumijima";
    repo = "KonomiTV";
    rev = "72dfc73542fb3995d2fb216facf98749c42b6114";
    hash = "sha256-SqT+R83/Frhdq5WVicccKLqRm6ENsQ0gahAfKzNDJXY=";
  };

  patches = [
    ./konomitv-immutable-paths.patch
  ];

  nativeBuildInputs = [ pkgs.makeWrapper ];

  dontBuild = true;

  postPatch = ''
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

    ${lib.optionalString pkgs.stdenv.hostPlatform.isx86_64 ''
      ln -s "${qsvenc}/bin/qsvencc" "$thirdpartyDir/QSVEncC/QSVEncC.elf"
      ln -s "${nvenc}/bin/nvencc" "$thirdpartyDir/NVEncC/NVEncC.elf"
    ''}

    cat > "$thirdpartyDir/VCEEncC/VCEEncC.elf" <<'EOF'
    #!${pkgs.bash}/bin/bash
    set -eo pipefail

    if [ -n "$DTV_NIX_VCEENCC_PATH" ] && [ -x "$DTV_NIX_VCEENCC_PATH" ]; then
      exec "$DTV_NIX_VCEENCC_PATH" "$@"
    fi

    if [ "$1" = "--check-hw" ]; then
      echo "unavailable. VCEEncC is an external requirement. Set DTV_NIX_VCEENCC_PATH to a VCEEncC executable."
    else
      echo "VCEEncC is an external requirement. Set DTV_NIX_VCEENCC_PATH to a VCEEncC executable." >&2
    fi
    exit 1
    EOF
    chmod +x "$thirdpartyDir/VCEEncC/VCEEncC.elf"

    cat > "$thirdpartyDir/rkmppenc/rkmppenc.elf" <<'EOF'
    #!${pkgs.bash}/bin/bash
    set -eo pipefail

    if [ -n "$DTV_NIX_RKMPPENC_PATH" ] && [ -x "$DTV_NIX_RKMPPENC_PATH" ]; then
      exec "$DTV_NIX_RKMPPENC_PATH" "$@"
    fi

    if [ "$1" = "--check-hw" ]; then
      echo "unavailable. rkmppenc is an external requirement. Set DTV_NIX_RKMPPENC_PATH to an rkmppenc executable."
    else
      echo "rkmppenc is an external requirement. Set DTV_NIX_RKMPPENC_PATH to an rkmppenc executable." >&2
    fi
    exit 1
    EOF
    chmod +x "$thirdpartyDir/rkmppenc/rkmppenc.elf"

    cat > "$out/bin/konomitv" <<EOF
    #!${pkgs.bash}/bin/bash
    set -eo pipefail

    template_dir="${placeholder "out"}/share/konomitv"

    if [ -n "\$XDG_STATE_HOME" ]; then
      state_root="\$XDG_STATE_HOME/konomitv"
    else
      state_root="\$HOME/.local/state/konomitv"
    fi

    if [ -z "\$KONOMITV_CONFIG_YAML_PATH" ]; then
      KONOMITV_CONFIG_YAML_PATH="\$state_root/config.yaml"
    fi

    if [ -z "\$KONOMITV_DATA_DIR" ]; then
      KONOMITV_DATA_DIR="\$state_root/data"
    fi

    if [ -z "\$KONOMITV_LOGS_DIR" ]; then
      KONOMITV_LOGS_DIR="\$state_root/logs"
    fi

    config_dir="\$(${pkgs.coreutils}/bin/dirname "\$KONOMITV_CONFIG_YAML_PATH")"

    mkdir -p \
      "\$config_dir" \
      "\$KONOMITV_DATA_DIR" \
      "\$KONOMITV_DATA_DIR/account-icons" \
      "\$KONOMITV_DATA_DIR/thumbnails" \
      "\$KONOMITV_LOGS_DIR"

    if [ ! -e "\$KONOMITV_CONFIG_YAML_PATH" ]; then
      cp "\$template_dir/config.yaml" "\$KONOMITV_CONFIG_YAML_PATH"
    fi

    export KONOMITV_CONFIG_YAML_PATH
    export KONOMITV_DATA_DIR
    export KONOMITV_LOGS_DIR
    export PATH="${headlessBrowser}/bin:$PATH"

    cd "\$template_dir/server"
    exec "${pythonEnv}/bin/python" KonomiTV.py "\$@"
    EOF
    chmod +x "$out/bin/konomitv"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Modern Japanese TV media server";
    homepage = "https://github.com/tsukumijima/KonomiTV";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "konomitv";
    platforms = platforms.linux;
  };
}
