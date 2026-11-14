{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  openssl,
  pcsclite,
  tsduck,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dantto4k";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "nekohkr";
    repo = "dantto4k";
    tag = "v${finalAttrs.version}";
    fetchSubmodules = true;
    hash = "sha256-dl8WkJ7IUL9fFIB5jtu2fVBKmYdXzBruHR3YJugJ6vg=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    openssl
    pcsclite
    tsduck
  ];

  postPatch = ''
    # Makefile が CRLF のため念のため正規化
    sed -i 's/\r$//' Makefile

    # 多くのヘッダが <cstdint> をインクルードせずに uint8_t 等を使っている。
    # MSVC では通るが、新しい GCC の標準ヘッダでは <cstdint> が暗黙に入らず
    # エラーになるため、Makefile の CXXFLAGS で強制的にインクルードする。
    substituteInPlace Makefile \
      --replace-fail "CXXFLAGS = -std=c++20" "CXXFLAGS = -std=c++20 -include cstdint"

    # nixpkgs の tsduck は SYSPREFIX=/ でビルドされており、tsduck.pc の prefix が
    # 空 (-I//include/tsduck) になって使えないため、pkg-config を使わず直接指定する
    substituteInPlace Makefile \
      --replace-fail '$(shell pkg-config --cflags-only-I tsduck)' \
        "-I${tsduck}/include/tsduck -I${tsduck}/include/tscore" \
      --replace-fail '$(shell pkg-config --libs tsduck)' \
        "-L${tsduck}/lib -L${tsduck}/lib64 -ltsduck -ltscore"
  '';

  makeFlags = [
    "CXX=${stdenv.cc.targetPrefix}c++"
  ];

  enableParallelBuilding = true;

  # Makefile の install は /usr/local/bin に cp するだけなので自前で配置する
  installPhase = ''
    runHook preInstall
    install -Dm755 build/dantto4k -t $out/bin
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--flake"
      "--version=stable"
    ];
  };

  meta = {
    description = "Decryptor and MMT/TLV to MPEG-2 TS converter for 4K broadcasts (ARIB STD-B32/B60)";
    homepage = "https://github.com/nekohkr/dantto4k";
    license = lib.licenses.asl20;
    mainProgram = "dantto4k";
    platforms = lib.platforms.linux;
  };
})
