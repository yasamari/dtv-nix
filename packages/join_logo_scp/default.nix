{ pkgs, ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "join_logo_scp";
  version = "4.1.0_Linux";

  src = pkgs.fetchFromGitHub {
    owner = "tobitti0";
    repo = "join_logo_scp";
    rev = "Ver${version}";
    hash = "sha256-rPFI4Tt2MkRQHyLjMAvLBxB1Ap1ocIczW0JDCdzYMig=";
  };

  sourceRoot = "source/src";

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

  meta = with pkgs.lib; {
    description = "JoinLogoScp command line tool and JL scripts";
    homepage = "https://github.com/tobitti0/join_logo_scp";
    license = licenses.gpl2Only;
    maintainers = [ ];
    mainProgram = "join_logo_scp";
    platforms = [ "x86_64-linux" ];
  };
}
