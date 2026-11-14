{ fetchFromGitHub, ... }:
{
  version = "0.14.1-unstable-2026-11-14";

  konomitvSrc = fetchFromGitHub {
    owner = "tsukumijima";
    repo = "KonomiTV";
    rev = "2774e39e512b5f3dfd423fdfc8a7602e92e844f5";
    hash = "sha256-L2OPmLKoiS0mNfyK5NvOZS3p8WIyu5Bqtf+XVGF5Pyo=";
  };
}
