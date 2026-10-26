{
  lib,
  stdenv,
  fetchFromGitHub,
  glibc,
  nix-update-script,
  ...
}:
stdenv.mkDerivation rec {
  pname = "join_logo_scp";
  version = "Ver4.1.0_Linux-unstable-2026-09-26";

  src = fetchFromGitHub {
    owner = "tobitti0";
    repo = "join_logo_scp";
    rev = "4dce4aa71efb7b55764f8dbd2277e5e45df331dd";
    hash = "sha256-c8sscFx88l8P8oDf0l6MjZNipHxbRUANsFx9rH5TNos=";
  };

  sourceRoot = "source/src";

  # Upstream makefile links with -static; glibc.static provides libc.a/libm.a.
  buildInputs = [ glibc.static ];

  buildPhase = ''
    runHook preBuild

    make

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -D -m 0755 join_logo_scp "$out/bin/join_logo_scp"
    mkdir -p "$out/share/join_logo_scp"
    cp -r ../JL "$out/share/join_logo_scp/JL"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--flake"
      "--version=branch=master"
    ];
  };

  meta = with lib; {
    description = "JoinLogoScp command line tool and JL scripts";
    homepage = "https://github.com/tobitti0/join_logo_scp";
    license = licenses.gpl2Only;
    maintainers = [ ];
    mainProgram = "join_logo_scp";
    platforms = [ "x86_64-linux" ];
  };
}
