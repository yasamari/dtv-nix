{ pkgs, ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "b24tovtt";
  version = "master-220402";

  src = pkgs.fetchFromGitHub {
    owner = "xtne6f";
    repo = "b24tovtt";
    rev = version;
    hash = "sha256-Ozl/QBqeHXvu/aRbNvTSmtEKEAmnLc2dYUSoaIhMKyE=";
  };

  strictDeps = true;
  dontConfigure = true;

  buildPhase = ''
    runHook preBuild
    make
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -D -m 755 b24tovtt "$out/bin/b24tovtt"
    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "Convert ARIB B24 captions to WebVTT";
    homepage = "https://github.com/xtne6f/b24tovtt";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "b24tovtt";
    platforms = platforms.linux;
  };
}
