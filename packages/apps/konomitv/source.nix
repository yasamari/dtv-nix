{ fetchFromGitHub, ... }:
{
  version = "0.14.1-unstable-2026-11-04";

  konomitvSrc = fetchFromGitHub {
    owner = "tsukumijima";
    repo = "KonomiTV";
    rev = "4223dff95aac4bfedf020df1264d41021ea921ae";
    hash = "sha256-UTk2pPMSh91AJE97IzRkMug973YoocztAY9lNYrXKAQ=";
  };
}
