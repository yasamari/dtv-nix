{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ...
}:
stdenv.mkDerivation rec {
  pname = "rgtools";
  version = "1.2";

  src = fetchFromGitHub {
    owner = "pinterf";
    repo = "RgTools";
    tag = version;
    hash = "sha256-xzJwJAuLxLUFidXZq5EaBFE8haclEYqKQ9aLVi2upD8=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    "-DCMAKE_INSTALL_LIBDIR=lib"
  ];

  meta = with lib; {
    description = "RgTools Avisynth plugin";
    homepage = "https://github.com/pinterf/RgTools";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
